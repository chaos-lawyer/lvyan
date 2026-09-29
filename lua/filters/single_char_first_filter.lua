-- 普通两键小鹤编码优先单个汉字；完整词组编码及 Emoji 等功能模式不受影响。
-- 此外，若首拼词库中有用户已选过的词条（type == "user_table"），优先提升至前列。
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
  local code = context.input or ""
  local segment = context.composition:back()
  local seg_len = segment and (segment._end - segment.start) or 0
  local is_short_normal_code = (seg_len == 2 or code:match("^[a-z][a-z]$"))
    and segment and segment:has_tag("abc")
  local is_in_nav = context.caret_pos < #code and seg_len <= 2

  local user_cands = {}
  local pending = {}
  local buffer_done = false

  for candidate in input:iter() do
    if is_in_nav and not is_single_han(candidate.text) then
      -- 光标回退至长句内单字音节逐字确认时，过滤掉词组联想，仅保留纯单字
    else
      if is_short_normal_code and is_single_han(candidate.text) then
        candidate.quality = 1000000
      end

      if not buffer_done then
        if candidate.type == "user_table" then
          table.insert(user_cands, candidate)
        else
          table.insert(pending, candidate)
        end

        if candidate.quality < 0.5 or #pending >= 30 then
          buffer_done = true
          for _, uc in ipairs(user_cands) do
            yield(uc)
          end
          for _, pc in ipairs(pending) do
            yield(pc)
          end
          user_cands = nil
          pending = nil
        end
      else
        yield(candidate)
      end
    end
  end

  if not buffer_done then
    if user_cands then
      for _, uc in ipairs(user_cands) do yield(uc) end
    end
    if pending then
      for _, pc in ipairs(pending) do yield(pc) end
    end
  end
end
