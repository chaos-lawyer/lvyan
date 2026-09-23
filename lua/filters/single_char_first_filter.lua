-- 普通两键小鹤编码优先单个汉字；完整词组编码及 Emoji 等功能模式不受影响。
local function is_single_han(text)
  local count = 0
  for _, cp in utf8.codes(text) do
    count = count + 1
    if count > 1 or not (
      (cp >= 0x3400 and cp <= 0x4DBF) or
      (cp >= 0x4E00 and cp <= 0x9FFF) or
      (cp >= 0xF900 and cp <= 0xFAFF)
    ) then
      return false
    end
  end
  return count == 1
end

return function(input, env)
  local context = env.engine.context
  local code = context.input
  local segment = context.composition:back()
  local is_short_normal_code = code:match("^[a-z][a-z]$")
    and segment and segment:has_tag("abc")

  for candidate in input:iter() do
    if is_short_normal_code and is_single_han(candidate.text) then
      candidate.quality = 1000000
    end
    yield(candidate)
  end
end
