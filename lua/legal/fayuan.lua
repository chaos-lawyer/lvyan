local set_mode_prompt = require("mode_prompt")

--[[
  fayuan.lua
  全国人民法院筛选翻译器（F 模式）
  触发方式：仅用 f + Tab（已彻底阻断大写字母 Shift+F 直接触发）
  功能特性：
  1. 候选窗采用竖排显示（由 fayuan_processor 与 vertical_layout option 联动控制）。
  2. 候选词为纯净法院全称（如“上海市高级人民法院”、“北京市海淀区人民法院”）。
  3. 候选词注释显示所属地区（如〔上海市〕、〔山西省太原市〕、〔全国〕）。
  4. 屏蔽「人民法院」：单独输入 rmfy/rm/fy 提示输入主体；输入尾随 rmfy/fy 自动容错剥离。
  5. 严格校验 context 的 tab_mode 属性为 "fayuan"，直接键盘输入大写 F 不触发。
--]]

local fayuan_data = require("fayuan_data")

-- 判断当前输入方案是否为小鹤双拼方案
local function is_flypy_scheme(env)
  local config = env.engine and env.engine.schema and env.engine.schema.config
  if config then
    local pinyin_type = config:get_string("fayuan/pinyin_type")
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
  -- 仅响应以 F 引导的输入
  local cmd = input:match("^F(.*)$")
  if not cmd then
    return
  end

  -- 统一仅用小写字母+tab 触发：校验 tab_mode 为 "fayuan"
  local context = env.engine and env.engine.context
  local tab_mode = context and context:get_property("tab_mode") or ""
  if tab_mode ~= "fayuan" then
    return
  end

  -- 设置说明提示，不在选项区占位
  set_mode_prompt(env, seg, "〔人民法院筛选〕")

  local is_flypy = is_flypy_scheme(env)

  -- 1. 单独输入 F 时展示最高法、主要高院及典型专门法院示例
  if cmd == "" then
    local top_items = fayuan_data.search("", is_flypy)
    for idx, item in ipairs(top_items) do
      local cand = Candidate("fayuan", seg.start, seg._end, item.text, "〔" .. item.comment .. "〕")
      cand.quality = 900000 - idx
      yield(cand)
    end
    return
  end

  local query = cmd:lower()

  -- 2. 屏蔽对“人民法院”泛词的单独筛选：输入 rmfy, rm, fy 时提示输入主体
  if query == "rmfy" or query == "rm" or query == "fy" then
    local tip_cand = Candidate("fayuan", seg.start, seg._end, "〔请输入法院地域或名称首拼〕", "")
    tip_cand.quality = 1000000
    yield(tip_cand)
    return
  end

  -- 3. 容错处理：若用户在法院主体后习惯性输入了 rmfy 或 fy，剥离末尾匹配主体
  if #query > 4 and query:sub(-4) == "rmfy" then
    query = query:sub(1, -5)
  elseif #query > 2 and query:sub(-2) == "fy" then
    query = query:sub(1, -3)
  end

  -- 4. 检索法院数据库
  local results = fayuan_data.search(query, is_flypy)
  if #results == 0 then
    local tip_cand = Candidate("fayuan", seg.start, seg._end, "〔无匹配法院〕", "首拼:" .. query)
    tip_cand.quality = 1000000
    yield(tip_cand)
    return
  end

  -- 5. 输出匹配候选：显示所属地区注释
  for idx, item in ipairs(results) do
    local cand = Candidate("fayuan", seg.start, seg._end, item.text, "〔" .. item.comment .. "〕")
    cand.quality = 1000000 - idx
    yield(cand)
  end
end

return translator
