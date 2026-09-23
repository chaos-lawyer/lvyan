local set_mode_prompt = require("mode_prompt")

--[[
  anyou.lua
  民事案由筛选翻译器（A 模式）
  触发方式：仅用 a + Tab（已删除大写字母直接触发）
  功能特性：
  1. 候选窗采用竖排显示（由 anyou_processor 与 vertical_layout option 联动控制）。
  2. 根据当前选用的全拼方案或小鹤双拼方案，采用对应的首拼字母。
  3. 屏蔽对「纠纷」的筛选，用户输入 jf 时明确不识别为「纠纷」。
  4. 严格校验 context 的 tab_mode 属性为 "anyou"，直接键盘输入大写 A 不触发。
--]]

local anyou_data = require("anyou_data")

-- 判断当前输入方案是否为小鹤双拼方案
local function is_flypy_scheme(env)
  local config = env.engine and env.engine.schema and env.engine.schema.config
  if config then
    local pinyin_type = config:get_string("anyou/pinyin_type")
    if pinyin_type == "flypy" then
      return true
    elseif pinyin_type == "quanpin" then
      return false
    end
  end

  local schema_id = (env.engine and env.engine.schema and env.engine.schema.schema_id) or ""
  if schema_id:find("flypy") or schema_id:find("double_pinyin") then
    return true
  end
  return false
end

local function translator(input, seg, env)
  -- 仅响应以 A 引导的输入
  local cmd = input:match("^A(.*)$")
  if not cmd then
    return
  end

  -- 统一仅用小写字母+tab 触发：校验 tab_mode 为 "anyou"
  local context = env.engine and env.engine.context
  local tab_mode = context and context:get_property("tab_mode") or ""
  if tab_mode ~= "anyou" then
    return
  end

  -- 设置说明提示，不在选项区占位
  set_mode_prompt(env, seg, "〔民事案由筛选〕")

  local is_flypy = is_flypy_scheme(env)

  -- 1. 单独输入 A 时展示高频案由示例
  if cmd == "" then
    local top_items = anyou_data.search("", is_flypy)
    for idx, item in ipairs(top_items) do
      local cand = Candidate("anyou", seg.start, seg._end, item.text, "〔" .. item.tag .. "〕")
      cand.quality = 900000 - idx
      yield(cand)
    end
    return
  end

  local query = cmd:lower()

  -- 2. 屏蔽对“纠纷”的筛选：用户输入 jf 时不识别为“纠纷”
  if query == "jf" then
    return
  end

  -- 3. 容错处理：若用户在案由主体后习惯性输入了 jf（如 Ammhtjf），剥离末尾 jf 匹配主体
  if #query > 2 and query:sub(-2) == "jf" then
    query = query:sub(1, -3)
  end

  -- 4. 检索案由数据库
  local results = anyou_data.search(query, is_flypy)
  if #results == 0 then
    local tip_cand = Candidate("anyou", seg.start, seg._end, "〔无匹配案由〕", "首拼:" .. query)
    tip_cand.quality = 1000000
    yield(tip_cand)
    return
  end

  -- 5. 输出匹配候选：显示案由级别与编号（如〔三级案由 96〕、〔四级案由 96.1〕）
  for idx, item in ipairs(results) do
    local comment = "〔" .. item.tag .. "〕"
    local cand = Candidate("anyou", seg.start, seg._end, item.text, comment)
    cand.quality = 1000000 - idx
    yield(cand)
  end
end

return translator
