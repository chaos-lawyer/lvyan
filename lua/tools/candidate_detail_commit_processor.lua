--[[
  侧窗详情上屏：组字期间按 =，将当前 candidate_detail 的正文直接上屏。

  详情由法律检索、罪名和固定候选等 Lua 模块写入 Context property，
  因此无需 Weasel 主程序参与。仅当确有详情且没有修饰键时拦截等号，
  普通输入中的 = / + 保持原有行为。
--]]

local kAccepted = 1
local kNoop = 2

-- 与 Weasel 的 ParseDetailPanelText 保持一致：展示用的 **…** 标记不
-- 应随正文上屏；\** 则表示用户希望得到字面量 **。
local function plain_detail_text(source)
  local result = {}
  local cursor = 1
  while cursor <= #source do
    if source:sub(cursor, cursor) == "\\"
        and source:sub(cursor + 1, cursor + 2) == "**" then
      result[#result + 1] = "**"
      cursor = cursor + 3
    elseif source:sub(cursor, cursor + 1) == "**" then
      local closing = source:find("**", cursor + 2, true)
      if closing and closing > cursor + 2 then
        result[#result + 1] = source:sub(cursor + 2, closing - 1)
        cursor = closing + 2
      else
        result[#result + 1] = source:sub(cursor, cursor)
        cursor = cursor + 1
      end
    else
      result[#result + 1] = source:sub(cursor, cursor)
      cursor = cursor + 1
    end
  end
  return table.concat(result)
end

local processor = {}

function processor.func(key, env)
  if key:release() or key:ctrl() or key:alt() or key:super() or key:shift() then
    return kNoop
  end

  local key_repr = key:repr() or ""
  if key_repr ~= "equal" and key_repr ~= "=" then return kNoop end

  local context = env.engine.context
  if not context:is_composing() then return kNoop end

  local detail = context:get_property("candidate_detail") or ""
  if detail == "" then return kNoop end

  local text = plain_detail_text(detail)
  if text == "" then return kNoop end

  env.engine:commit_text(text)
  context:clear()
  return kAccepted
end

return processor
