-- 单独点按右 Shift 切换全角/半角；右 Shift+` / ' / , / . 输入专用符号。
local M = {}
local kAccepted, kNoop = 1, 2
local RIGHT_SHIFT = 0xFFE2
local GRAVE = string.byte("`")
local TILDE = string.byte("~")
local APOSTROPHE = string.byte("'")
local DOUBLE_QUOTE = string.byte('"')
local COMMA = string.byte(",")
local LESS = string.byte("<")
local PERIOD = string.byte(".")
local GREATER = string.byte(">")

local function commit_symbol(env, symbol)
  local context = env.engine.context
  local composing = context:is_composing()
  local prefix = ""
  if composing and context.get_commit_text then
    prefix = context:get_commit_text() or ""
  end
  env.engine:commit_text(prefix .. symbol)
  if composing then context:clear() end
end

function M.init(env)
  env.right_shift_pressed = false
  env.right_shift_used = false
  env.next_left_quote = true
end

function M.func(key, env)
  if key.keycode == RIGHT_SHIFT then
    if not key:release() then
      env.right_shift_pressed = true
      env.right_shift_used = key:ctrl() or key:alt() or key:super()
      return kNoop
    end

    local toggle = env.right_shift_pressed and not env.right_shift_used
      and not key:ctrl() and not key:alt() and not key:super()
    env.right_shift_pressed = false
    env.right_shift_used = false
    if toggle then
      local context = env.engine.context
      context:set_option("full_shape", not context:get_option("full_shape"))
      return kAccepted
    end
    return kNoop
  end

  if env.right_shift_pressed and not key:release() then
    env.right_shift_used = true
    if key:shift() and not key:ctrl() and not key:alt() and not key:super() then
      -- Windows 的 ToUnicodeEx 通常把 Shift+` / ' / , / . 送成 ~ / " / < / >。
      if key.keycode == GRAVE or key.keycode == TILDE then
        commit_symbol(env, "`")
        return kAccepted
      elseif key.keycode == APOSTROPHE or key.keycode == DOUBLE_QUOTE then
        commit_symbol(env, env.next_left_quote and "「" or "」")
        env.next_left_quote = not env.next_left_quote
        return kAccepted
      elseif key.keycode == COMMA or key.keycode == LESS then
        commit_symbol(env, "〈")
        return kAccepted
      elseif key.keycode == PERIOD or key.keycode == GREATER then
        commit_symbol(env, "〉")
        return kAccepted
      end
    end
  end
  return kNoop
end

return M
