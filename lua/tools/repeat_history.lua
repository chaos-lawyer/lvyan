--[[
  repeat_history.lua
  Rime 输入历史 (h+Tab) 与 重复上次输出 (i+Tab) 独立功能模块

  功能特性：
  1. h + Tab:
     - 调出最近 10 条输入历史记录（按最近输入倒序排列）；
     - 使用原生候选窗口展示：文本为候选内容，编码为注释；
     - 选择某条历史记录后，不直接输出该文本，而是将原始编码恢复注入输入框，
       重新唤起原生候选，完全兼容直接辅助码及后续拼写筛选；
     - 仅在 context.input == "h" 并按 Tab 时触发，普通 h 开头的输入完全不受影响。
  2. i + Tab:
     - 直接重复输出最近一次正常输入的文本 (last_text)；
     - 自身输出不被计入历史记录，且不污染 last_text；
     - 仅在 context.input == "i" 并按 Tab 时触发，普通 i 开头的输入完全不受影响。
  3. 过滤隔离：
     - 空字符串、单纯标点、功能前缀及功能模式（法律条文 d、案由 a、罪名 z、
       LPR l、金额计算器 v、日期 r/rl、表情 e、拆字 u）默认不进入输入历史。
  4. 历史上限与去重：
     - 最多保留 10 条记录，先进先出；
     - 完全相同的 code + text 自动去重并置顶到最新一位。
--]]

local M = {}

M.history = {}
M.last_text = nil
M.is_repeating = false
M.max_history = 10

--------------------------------------------------------------------------------
-- 集中过滤判定：是否允许将当前 commit 上屏记录到输入历史
--------------------------------------------------------------------------------
function M.is_eligible_record(input, commit_text, tab_mode)
  -- 1. 由 i + Tab 重复功能触发的上屏严禁写入历史
  if M.is_repeating then
    return false
  end

  -- 2. 空输入或空输出
  if not input or input == "" or not commit_text or commit_text == "" then
    return false
  end

  -- 3. 纯空白字符
  if commit_text:match("^%s+$") then
    return false
  end

  -- 4. 处于任何 Tab 引导的功能模式（案由 anyou, 罪名 zuiming, lpr, v, r/rl, e, u, history 等）
  if tab_mode and tab_mode ~= "" then
    return false
  end

  -- 5. 法律条文模式 (d / D + 纯数字或带点节次)
  if input:match("^[Dd]%d") then
    return false
  end

  -- 6. 必须包含至少一个普通字母（排除纯标点符号上屏）
  if not input:match("[a-zA-Z]") then
    return false
  end

  -- 7. 排除单个大写字母引导键本身残留
  if input:match("^[A-Z]$") then
    return false
  end

  return true
end

--------------------------------------------------------------------------------
-- 历史记录增添与去重管理
--------------------------------------------------------------------------------
function M.add_record(code, text)
  if not code or not text or code == "" or text == "" then
    return
  end

  -- 更新最近一次正常上屏的文本
  M.last_text = text

  -- 去重：查找 code 与 text 均完全相同的旧条目
  local found_index = nil
  for i, item in ipairs(M.history) do
    if item.code == code and item.text == text then
      found_index = i
      break
    end
  end

  if found_index then
    table.remove(M.history, found_index)
  end

  -- 新记录置顶插入到第 1 位
  table.insert(M.history, 1, { code = code, text = text })

  -- 保持最多 10 条
  while #M.history > M.max_history do
    table.remove(M.history)
  end
end

--------------------------------------------------------------------------------
-- Translator 组件实现：渲染历史候选列表
--------------------------------------------------------------------------------
local function translator_func(input, seg, env)
  local context = env.engine.context
  local tab_mode = context:get_property("tab_mode") or ""

  if input == "H" and tab_mode == "history" then
    if #M.history == 0 then
      local cand = Candidate("history", seg.start, seg._end, "〔暂无输入历史〕", "")
      cand.quality = 1000
      yield(cand)
      return
    end

    for idx, item in ipairs(M.history) do
      local cand = Candidate("history", seg.start, seg._end, item.text, item.code)
      cand.quality = 100000 - idx
      yield(cand)
    end
  end
end

M.translator = translator_func

--------------------------------------------------------------------------------
-- Processor 组件实现：按键触发、选词拦截与编码恢复
--------------------------------------------------------------------------------
M.processor = {}

local key_map = {
  ["1"] = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5,
  [";"] = 2, ["'"] = 3,
}

local kAccepted = 1
local kNoop = 2

function M.processor.init(env)
  local context = env.engine.context
  env.page_size = 5
  if env.engine.schema and env.engine.schema.config then
    env.page_size = env.engine.schema.config:get_int("menu/page_size") or 5
  end

  -- 监听所有有效上屏事件
  env.commit_connection = context.commit_notifier:connect(function(ctx)
    local inp = ctx.input or ""
    local commit_text = ctx.get_commit_text and ctx:get_commit_text() or ""
    local tab_mode = ctx:get_property("tab_mode") or ""

    if M.is_eligible_record(inp, commit_text, tab_mode) then
      M.add_record(inp, commit_text)
    end
  end)
end

function M.processor.fini(env)
  if env.commit_connection then
    env.commit_connection:disconnect()
    env.commit_connection = nil
  end
end

function M.processor.func(key, env)
  if key:release() then return kNoop end
  local repr = key:repr()

  local context = env.engine.context
  local inp = context.input or ""
  local tab_mode = context:get_property("tab_mode") or ""

  -- 1. 功能引导触发拦截（仅无 Ctrl/Alt/Super 修饰键的纯 Tab 键生效）
  local history_tab_enabled = true
  if env.engine.schema and env.engine.schema.config then
    local configured = env.engine.schema.config:get_bool("tab_mode_switches/history")
    if configured ~= nil then history_tab_enabled = configured end
  end
  if history_tab_enabled and repr == "Tab"
      and not (key:ctrl() or key:alt() or key:super()) then
    -- h + Tab: 仅当当前 composition 只有 "h" 时触发
    if inp == "h" then
      context:clear()
      context:set_property("tab_mode", "history")
      context:push_input("H")
      return kAccepted
    -- i + Tab: 仅当当前 composition 只有 "i" 时触发
    elseif inp == "i" then
      context:clear()
      if M.last_text and M.last_text ~= "" then
        M.is_repeating = true
        env.engine:commit_text(M.last_text)
        M.is_repeating = false
      end
      return kAccepted
    end
  end

  -- 2. 处于历史模式时的候选拦截与行为控制
  if tab_mode == "history" and inp == "H" then
    -- 按 Escape 取消历史模式，恢复初始状态
    if repr == "Escape" then
      context:clear()
      context:set_property("tab_mode", "")
      return kAccepted
    end

    local choice = nil
    if repr == "space" or repr == "Return" then
      -- 空格或回车选择当前高亮候选
      local composition = context.composition
      local seg = composition and not composition:empty() and composition:back()
      local sel_index = seg and seg.selected_index or 0
      choice = sel_index + 1
    elseif key_map[repr] and not (key:ctrl() or key:alt() or key:super()) then
      local sel_num = key_map[repr]
      local composition = context.composition
      local seg = composition and not composition:empty() and composition:back()
      local sel_index = seg and seg.selected_index or 0
      local page_sz = env.page_size or 5
      local page_start = math.floor(sel_index / page_sz) * page_sz
      choice = page_start + sel_num
    end

    if choice then
      if #M.history == 0 then
        -- 暂无历史时选词直接退出
        context:clear()
        context:set_property("tab_mode", "")
        return kAccepted
      end

      local item = M.history[choice]
      if item then
        local code_to_restore = item.code
        context:clear()
        context:set_property("tab_mode", "")
        -- 核心：重新注入原始编码，唤起正常双拼候选
        context:push_input(code_to_restore)
        return kAccepted
      end
    end

    -- 翻页键放行给原生 selector 处理
    if repr == "Page_Up" or repr == "Page_Down" or repr == "Up" or repr == "Down" then
      return kNoop
    end

    -- 退格键退出历史模式
    if repr == "BackSpace" then
      context:clear()
      context:set_property("tab_mode", "")
      return kAccepted
    end

    -- 用户直接输入其他普通按键，退出历史模式并放行让正常输入接管
    if not (key:ctrl() or key:alt() or key:super()) and #repr == 1 then
      context:clear()
      context:set_property("tab_mode", "")
      return kNoop
    end
  end

  -- 其他所有情况均返回 kNoop，绝不影响原有输入链及其他功能模式
  return kNoop
end

return M
