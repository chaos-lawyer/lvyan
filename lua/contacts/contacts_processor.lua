--[[
  contacts_processor.lua
  N 通讯录模式键盘处理器：
  1. 拦截选词键（主键盘 1~9、小键盘 1~9、Space、Return/KP_Enter、分号、单引号）
  2. 实现【显示姓名、上屏手机号】的真正分离：
     通过 search.get_commit_value 取得选中联系人的实际号码，
     调用 engine:commit_text 提交，彻底防止将候选词文本（姓名）直接上屏
  3. 支持电话号码检索：
     当检索编码为数字时，数字键作为检索输入追加（不误当作选词），
     检索完成后通过 Space、Enter、分号或单引号选词上屏
  4. 支持 Esc 键或退格清空编码直接退出通讯录模式
  5. 上屏完成后自动清除输入、退出通讯录模式并恢复普通输入状态
--]]

local search = require("contacts_search")
local layout_manager = require("layout_manager")

local M = {}
local kAccepted = 1
local kNoop = 2

local function clear_mode_state(context)
  context:set_property("tab_mode", "")
  context:set_property("tab_mode_display", "")
  context:set_property("tab_mode_prefix", "")
  context:set_property("candidate_select_keys", "")
  layout_manager.sync(context)
end

function M.init(env)
  env.page_size = 5
  if env.engine and env.engine.schema and env.engine.schema.config then
    env.page_size = env.engine.schema.config:get_int("menu/page_size") or 5
  end
end

function M.fini(env)
end

function M.func(key, env)
  if key:release() then return kNoop end

  local context = env.engine and env.engine.context
  if not context or not context:is_composing() then
    return kNoop
  end

  local tab_mode = context:get_property("tab_mode") or ""
  if tab_mode ~= "contacts" then
    return kNoop
  end

  local repr = key:repr() or ""

  -- 1. Escape: 清空编码并退出模式
  if repr == "Escape" or (key:ctrl() and repr == "g") then
    context:clear()
    clear_mode_state(context)
    return kAccepted
  end

  local input = context.input or ""
  local query = input:match("^N(.*)$") or ""

  -- 2. BackSpace: 若编码只剩前缀 N，直接清除并退出模式
  if repr == "BackSpace" then
    if input == "N" or input == "" then
      context:clear()
      clear_mode_state(context)
      return kAccepted
    end
    return kNoop
  end

  -- 3. 选词键解析（数字键 1~9、小键盘 1~9、Space、Return、分号、单引号始终用于选词）
  local target_index = nil
  local composition = context.composition
  local seg = composition and not composition:empty() and composition:back()
  local sel_index = (seg and seg.selected_index) or 0
  local page_size = env.page_size or 5
  local page_start = math.floor(sel_index / page_size) * page_size

  if repr == "space" or repr == "Space" or repr == "Return" or repr == "KP_Enter" then
    target_index = sel_index
  elseif repr == "semicolon" or repr == ";" then
    target_index = page_start + 1
  elseif repr == "apostrophe" or repr == "'" then
    target_index = page_start + 2
  elseif repr:match("^[1-9]$") then
    local num = tonumber(repr)
    if num and num <= page_size then
      target_index = page_start + (num - 1)
    end
  elseif repr:match("^KP_([1-9])$") then
    local num = tonumber(repr:match("^KP_([1-9])$"))
    if num and num <= page_size then
      target_index = page_start + (num - 1)
    end
  end

  if target_index ~= nil then
    local commit_val = search.get_commit_value(target_index)
    if commit_val and commit_val ~= "" then
      env.engine:commit_text(commit_val)
    end
    context:clear()
    clear_mode_state(context)
    return kAccepted
  end

  return kNoop
end

return M
