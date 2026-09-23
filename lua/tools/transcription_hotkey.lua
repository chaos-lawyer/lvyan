-- 输入过程中独占 Ctrl+Shift+T：兼容大小写 / Caps Lock，消费按下和抬起。
-- 放在 ascii_composer 和 recognizer 前，重复按下只切换一次。
local M = {}
local kAccepted, kNoop = 1, 2

function M.init(env)
  env.t_pressed = false
end

function M.func(key, env)
  local is_t = key.keycode == string.byte("t") or key.keycode == string.byte("T")
  if key:release() then
    -- Ctrl/Shift 可能先松开，不能要求抬 F 时仍带着两个修饰键。
    if is_t and env.t_pressed then
      env.t_pressed = false
      return kAccepted
    end
    return kNoop
  end

  local shortcut = is_t and key:ctrl() and key:shift() and not key:alt() and not key:super()
  if not shortcut then
    -- 前端丢失抬键或切走焦点后，下一次普通按键恢复正常状态。
    if key.keycode < 0xFFE1 or key.keycode > 0xFFEE then
      env.t_pressed = false
    end
    return kNoop
  end
  if env.t_pressed then return kAccepted end

  local context = env.engine.context
  if not context:is_composing() or context:get_option("ascii_mode") then
    return kNoop
  end
  env.t_pressed = true
  context:set_option("transcription", not context:get_option("transcription"))
  return kAccepted
end

return M
