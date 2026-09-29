--[[
  ctrl_syllable_nav_processor.lua
  支持用 Ctrl+字母 在拼音长句中按声母快速定位光标。

  功能逻辑：
  1. 捕获 Ctrl + 字母（Control+[a-z]）：
     - 检查当前处于中文组词（composing）且无特殊模式；
     - 解析按键对应的目标字母（声母）；
  2. 扫描双拼音节：
     - 在双拼方案中，每个汉字音节由 2 个字母组成（起始位 0, 2, 4, ...）；
     - 收集所有首字母匹配目标声母的音节；
  3. 光标定位与循环跳转：
     - 默认将光标移动至目标音节后面（caret = end_pos），便于直接键入辅码筛选或退格；
       （可在方案配置中设置 syllable_nav/target_placement: "start" 改为停在音节前）；
     - 若句中存在多个同声母音节（如 lb 与 lc 均为 l），连续按 Ctrl+l 在这些音节间依次循环；
  4. 降级透传：
     - 若当前输入中无任何音节匹配该字母，返回 kNoop 透传给后续处理器（如 Emacs 键位）。
--]]

local kAccepted = 1
local kNoop = 2

local processor = {}

local function extract_ctrl_letter(key)
  if not key:ctrl() or key:alt() or key:super() or key:shift() then
    return nil
  end

  local repr = key:repr()
  local letter = repr:match("^Control%+([a-zA-Z])$")
  if letter then
    return letter:lower()
  end

  -- 兼容终端/不同平台键码
  local kc = key.keycode
  if kc >= 1 and kc <= 26 then
    return string.char(kc + 96)
  elseif kc >= 97 and kc <= 122 then
    return string.char(kc)
  elseif kc >= 65 and kc <= 90 then
    return string.char(kc + 32)
  end

  return nil
end

function processor.init(env)
  -- 读取配置项：光标落点默认在音节后 ("end")，亦可配置为音节前 ("start")
  local config = env.engine.schema.config
  env.target_placement = config:get_string("syllable_nav/target_placement") or "end"
end

function processor.func(key, env)
  if key:release() then return kNoop end

  local letter = extract_ctrl_letter(key)
  if not letter then return kNoop end

  local context = env.engine.context
  if not context:is_composing() then return kNoop end

  -- 若处于特殊模式（如 v 计算器、r 日期等），不干涉
  local tab_mode = context:get_property("tab_mode") or ""
  if tab_mode ~= "" then return kNoop end

  local raw_input = context.input or ""
  if #raw_input < 2 then return kNoop end

  -- 扫描双拼音节（2 码一字）
  local matches = {}
  local syllables_count = math.floor(#raw_input / 2)
  for k = 1, syllables_count do
    local start_idx = (k - 1) * 2
    local initial = raw_input:sub(start_idx + 1, start_idx + 1):lower()
    if initial == letter then
      local end_idx = math.min(k * 2, #raw_input)
      local target_pos = (env.target_placement == "start") and start_idx or end_idx
      table.insert(matches, target_pos)
    end
  end

  if #matches == 0 then
    -- 无匹配音节，透传
    return kNoop
  end

  -- 在多个匹配位置间循环前进
  local current_caret = context.caret_pos
  local next_caret = nil
  for _, pos in ipairs(matches) do
    if pos > current_caret then
      next_caret = pos
      break
    end
  end

  if not next_caret then
    next_caret = matches[1] -- 循环回第一个匹配项
  end

  context.caret_pos = next_caret
  return kAccepted
end

return processor
