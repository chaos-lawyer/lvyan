-- Emoji 表情模式只保留表情：排除原中文、英文及货币缩写等 OpenCC 替换结果。
-- 保留组合表情中的肤色、连接符、变体选择符、旗帜及键帽序列。
local function is_emoji(text)
  local has_symbol = false
  for _, cp in utf8.codes(text) do
    if (cp >= 0x1F000 and cp <= 0x1FAFF)
      or (cp >= 0x2600 and cp <= 0x27BF)
      or (cp >= 0x2194 and cp <= 0x2199)
      or cp == 0x21A9 or cp == 0x21AA
      or cp == 0x231A or cp == 0x231B or cp == 0x2328 or cp == 0x23CF
      or (cp >= 0x23E9 and cp <= 0x23F3)
      or (cp >= 0x23F8 and cp <= 0x23FA)
      or cp == 0x24C2 or cp == 0x25AA or cp == 0x25AB
      or cp == 0x25B6 or cp == 0x25C0
      or (cp >= 0x25FB and cp <= 0x25FE)
      or cp == 0x2934 or cp == 0x2935
      or (cp >= 0x2B05 and cp <= 0x2B07)
      or cp == 0x2B1B or cp == 0x2B1C or cp == 0x2B50 or cp == 0x2B55
      or cp == 0x3030 or cp == 0x303D or cp == 0x3297 or cp == 0x3299
      or cp == 0x00A9 or cp == 0x00AE or cp == 0x203C or cp == 0x2049
      or cp == 0x2122 or cp == 0x2139 or cp == 0x20E3 then
      has_symbol = true
    elseif cp == 0x200D or cp == 0xFE0F or cp == 0xFE0E
      or (cp >= 0xE0020 and cp <= 0xE007F)
      or (cp >= 0x30 and cp <= 0x39) or cp == 0x23 or cp == 0x2A then
      -- 序列辅助字符；单独出现时不算表情。
    else
      return false
    end
  end
  return has_symbol
end

return function(input, env)
  local segment = env.engine.context.composition:back()
  local emoji_mode = segment and segment:has_tag("emoji")
  for candidate in input:iter() do
    if not emoji_mode or is_emoji(candidate.text) then
      yield(candidate)
    end
  end
end
