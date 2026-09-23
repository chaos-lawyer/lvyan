local set_mode_prompt = require("mode_prompt")

--[[
  zuiming.lua
  刑法罪名筛选翻译器（Z 模式）
  触发方式：仅用 z + Tab（已删除大写字母直接触发）
  功能特性：
  1. 候选窗采用竖排显示（由 zuiming_processor 与 vertical_layout option 联动控制）。
  2. 根据当前选用的全拼方案或小鹤双拼方案，采用对应的首拼字母。
  3. 候选词保持纯粹罪名名称或章节名称，罪名法条在侧窗显示。
  4. 候选词注释显示章节与法条号（如〔第二章 第114条〕、〔第三章第一节 第140条〕、〔第一章〕）。
  5. 严格校验 context 的 tab_mode 属性为 "zuiming"，直接键盘输入大写 Z 不触发。
--]]

local zuiming_data = require("zuiming_data")

-- 判断当前输入方案是否为小鹤双拼方案
local function is_flypy_scheme(env)
  local config = env.engine and env.engine.schema and env.engine.schema.config
  if config then
    local pinyin_type = config:get_string("zuiming/pinyin_type")
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
  -- 仅响应以 Z 引导的输入
  local cmd = input:match("^Z(.*)$")
  if not cmd then
    return
  end

  -- 统一仅用小写字母+tab 触发：校验 tab_mode 为 "zuiming"
  local context = env.engine and env.engine.context
  local tab_mode = context and context:get_property("tab_mode") or ""
  if tab_mode ~= "zuiming" then
    return
  end

  -- 设置说明提示，不在选项区占位
  set_mode_prompt(env, seg, "〔刑法罪名筛选〕")

  local is_flypy = is_flypy_scheme(env)

  -- 1. 单独输入 Z 时展示高频罪名及主要章节示例
  if cmd == "" then
    local top_items = zuiming_data.search("", is_flypy)
    for idx, item in ipairs(top_items) do
      local cand = Candidate("zuiming", seg.start, seg._end, item.text, item.comment)
      cand.quality = 900000 - idx
      yield(cand)
    end
    return
  end

  local query = cmd:lower()

  -- 2. 避免单字 "z" 或 "zm" 匹配海量全部以"罪"结尾的项目
  if query == "z" or query == "zm" then
    local tip_cand = Candidate("zuiming", seg.start, seg._end, "〔请输入罪名主体首拼〕", "")
    tip_cand.quality = 1000000
    yield(tip_cand)
    return
  end

  -- 3. 容错处理：若用户在罪名主体后习惯性输入了 zm（罪名），剥离末尾 zm 匹配主体
  if #query > 2 and query:sub(-2) == "zm" then
    query = query:sub(1, -3)
  end

  -- 4. 检索罪名数据库
  local results = zuiming_data.search(query, is_flypy)
  if #results == 0 then
    local tip_cand = Candidate("zuiming", seg.start, seg._end, "〔无匹配罪名〕", "首拼:" .. query)
    tip_cand.quality = 1000000
    yield(tip_cand)
    return
  end

  -- 4. 输出匹配候选：显示章节与法条号
  for idx, item in ipairs(results) do
    local cand = Candidate("zuiming", seg.start, seg._end, item.text, item.comment)
    cand.quality = 1000000 - idx
    yield(cand)
  end
end

return translator
