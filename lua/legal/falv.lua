local set_mode_prompt = require("mode_prompt")

--[[
  falv.lua
  国家法律文件检索翻译器（G 模式）
  法律检索现由 F 综合入口承载；此翻译器保留作旧配置兼容，不再单独触发
  功能特性：
  1. 候选窗采用竖排显示（由 falv_processor 与 vertical_layout option 联动控制）。
  2. 根据当前选用的全拼方案或小鹤双拼方案，采用对应的首拼字母。
  3. 候选词为纯净法律全称（如“中华人民共和国公司法”、“中华人民共和国民法典”）。
  4. 候选词注释显示时效性状态（如〔现行有效〕、〔尚未生效〕、〔已修改〕、〔已废止〕）。
  5. 屏蔽‘中华人民共和国’：单独输入 zh/zhrm/zhrmghg（全拼）或 vh/vhrm/vhrmghg（小鹤）提示输入主体；附带前缀自动容错剥离。
  6. 严格校验 context 的 tab_mode 属性为 "falv"，直接键盘输入大写 G 不触发。
--]]

local falv_data = require("falv_data")

-- 判断当前输入方案是否为小鹤双拼方案
local function is_flypy_scheme(env)
  local config = env.engine and env.engine.schema and env.engine.schema.config
  if config then
    local pinyin_type = config:get_string("falv/pinyin_type")
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
  -- 仅响应以 G 引导的输入
  local cmd = input:match("^G(.*)$")
  if not cmd then
    return
  end

  -- 统一仅用小写字母+tab 触发：校验 tab_mode 为 "falv"
  local context = env.engine and env.engine.context
  local tab_mode = context and context:get_property("tab_mode") or ""
  if tab_mode ~= "falv" then
    return
  end

  -- 设置说明提示，不在选项区占位
  set_mode_prompt(env, seg, "〔法律文件检索〕")

  local is_flypy = is_flypy_scheme(env)

  -- 1. 单独输入 G 时展示核心基本法律示例
  if cmd == "" then
    local top_items = falv_data.search("", is_flypy)
    for idx, item in ipairs(top_items) do
      local cand = Candidate("falv", seg.start, seg._end, item.text, item.comment)
      cand.quality = 900000 - idx
      yield(cand)
    end
    return
  end

  local query = cmd:lower()

  -- 2. 屏蔽对“中华人民共和国”泛词的单独筛选：单独输入 zh/zhrm/zhrmghg/vh/vhrm/vhrmghg 提示输入主体
  if query == "zhrmghg" or query == "zhrm" or query == "zh" or
     query == "vhrmghg" or query == "vhrm" or query == "vh" then
    local tip_cand = Candidate("falv", seg.start, seg._end, "〔请输入法律名称主体首拼〕", "已屏蔽‘中华人民共和国’")
    tip_cand.quality = 1000000
    yield(tip_cand)
    return
  end

  -- 3. 容错处理：若用户在输入主体前习惯性附带了中华人民共和国的前缀，剥离前缀匹配主体
  if #query > 7 and (query:sub(1, 7) == "zhrmghg" or query:sub(1, 7) == "vhrmghg") then
    query = query:sub(8)
  elseif #query > 4 and (query:sub(1, 4) == "zhrm" or query:sub(1, 4) == "vhrm") then
    query = query:sub(5)
  elseif #query > 2 and (query:sub(1, 2) == "zh" or query:sub(1, 2) == "vh") then
    query = query:sub(3)
  end

  if query == "" then
    local tip_cand = Candidate("falv", seg.start, seg._end, "〔请输入法律名称主体首拼〕", "")
    tip_cand.quality = 1000000
    yield(tip_cand)
    return
  end

  -- 4. 检索法律数据库
  local results = falv_data.search(query, is_flypy)
  if #results == 0 then
    local tip_cand = Candidate("falv", seg.start, seg._end, "〔无匹配法律文件〕", "首拼:" .. query)
    tip_cand.quality = 1000000
    yield(tip_cand)
    return
  end

  -- 5. 输出匹配候选：显示时效性注释
  for idx, item in ipairs(results) do
    local cand = Candidate("falv", seg.start, seg._end, item.text, item.comment)
    cand.quality = 1000000 - idx
    yield(cand)
  end
end

return translator
