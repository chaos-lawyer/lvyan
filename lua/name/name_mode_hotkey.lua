--[[
  name_mode_hotkey.lua
  输入过程中独占 Ctrl+Shift+M：兼容大小写 / Caps Lock，消费按下和抬起。
  对标 transcription_hotkey.lua（Ctrl+Shift+T 繁简切换）。
  放在 ascii_composer 和 recognizer 前，重复按下只切换一次。
--]]

local M = {}
local kAccepted, kNoop = 1, 2

function M.init(env)
  env.m_pressed = false
end

function M.func(key, env)
  local is_m = key.keycode == string.byte("m") or key.keycode == string.byte("M")
  if key:release() then
    -- Ctrl/Shift 可能先松开，不能要求抬 M 时仍带着两个修饰键。
    if is_m and env.m_pressed then
      env.m_pressed = false
      return kAccepted
    end
    return kNoop
  end

  local shortcut = is_m and key:ctrl() and key:shift() and not key:alt() and not key:super()
  if not shortcut then
    -- 前端丢失抬键或切走焦点后，下一次普通按键恢复正常状态。
    if key.keycode < 0xFFE1 or key.keycode > 0xFFEE then
      env.m_pressed = false
    end
    return kNoop
  end
  if env.m_pressed then return kAccepted end

  local context = env.engine.context
  if not context:is_composing() or context:get_option("ascii_mode") then
    return kNoop
  end
  env.m_pressed = true
  local cur_mode = context:get_property("tab_mode") or ""
  if cur_mode ~= "" then
    -- 若当前处于通讯录等筛选模式，剥离模式前缀并切换到人名模式
    local input = context.input or ""
    local prefix = context:get_property("tab_mode_prefix") or ""
    local raw = input
    if prefix ~= "" and input:sub(1, #prefix) == prefix then
      raw = input:sub(#prefix + 1)
    elseif input:sub(1, 1) == "N" then
      raw = input:sub(2)
    end
    context:clear()
    if raw ~= "" then
      context:push_input(raw)
    end
    context:set_property("tab_mode", "")
    context:set_property("tab_mode_display", "")
    context:set_property("tab_mode_prefix", "")
    context:set_property("candidate_select_keys", "")
    context:set_option("name_mode", true)
    local layout_manager = require("layout_manager")
    layout_manager.sync(context)
    return kAccepted
  end

  context:set_option("name_mode", not context:get_option("name_mode"))
  return kAccepted
end

return M
