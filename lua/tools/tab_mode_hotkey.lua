-- 在普通拼音/双拼编码过程中，用 Ctrl+Shift+A/Z/F/L/E/B 将当前编码带入筛选模式。
-- 已进入某个筛选模式时，同一快捷键可以直接切换到另一模式，并保留原查询编码。
local M = {}
local kAccepted, kNoop = 1, 2

local modes = {
  a = { prefix = "A", mode = "anyou", display = "a" },
  z = { prefix = "Z", mode = "zuiming", display = "z" },
  f = { prefix = "F", mode = "legal_search", display = "f" },
  e = { prefix = "E", mode = "english", display = "e", config_key = "english", horizontal = true },
  b = { prefix = "B", mode = "emoji", display = "b", horizontal = true },
}

local auxiliary_modes = {
  { prefix = "L", mode = "lpr" },
  { prefix = "F", mode = "fayuan" },
}

local function config_bool(config, path, fallback)
  local value = config:get_bool(path)
  if value == nil then return fallback end
  return value
end

local function enabled(env, letter)
  local config = env.engine.schema.config
  local mode = modes[letter]
  local config_key = (mode and mode.config_key) or letter
  return config_bool(config, "tab_mode_switches/enabled", true)
    and config_bool(config, "tab_mode_switches/" .. config_key, true)
end

local function key_letter(key)
  for letter in pairs(modes) do
    if key.keycode == string.byte(letter) or
        key.keycode == string.byte(letter:upper()) then
      return letter
    end
  end
end

function M.init(env)
  env.tab_mode_hotkey_pressed = {}
end

local function clear_mode_state(context)
  context:set_property("tab_mode", "")
  context:set_property("tab_mode_display", "")
  context:set_property("tab_mode_prefix", "")
  if context.set_option then context:set_option("vertical_layout", false) end
  context:set_property("candidate_select_keys", "")
end

local function source_input(context)
  local input = context.input or ""
  local active_mode = context:get_property("tab_mode") or ""
  if active_mode == "" then return input end

  -- 仅从本处理器创建的模式中剥离隐藏前缀，避免接管无关的 composing 状态。
  for _, mode in pairs(modes) do
    if mode.mode == active_mode and input:sub(1, 1) == mode.prefix then
      return input:sub(2)
    end
  end
  for _, mode in ipairs(auxiliary_modes) do
    if mode.mode == active_mode and input:sub(1, 1) == mode.prefix then
      return input:sub(2)
    end
  end
  return nil
end

function M.func(key, env)
  local letter = key_letter(key)
  local pressed = env.tab_mode_hotkey_pressed

  if key:release() then
    -- 修饰键常常先于字母抬起，因此只按此前记录判断是否消费抬键。
    if letter and pressed[letter] then
      pressed[letter] = nil
      return kAccepted
    end
    return kNoop
  end

  local context = env.engine.context
  -- English 模式的 E 是隐藏引导前缀；显式清空才能让 Escape 与其他模式
  -- 一样一次取消整段编码，而不是只撤回末尾字符。
  if key:repr() == "Escape" and
      (context:get_property("tab_mode") or "") == "english" then
    context:clear()
    clear_mode_state(context)
    return kAccepted
  end

  local shortcut = letter and key:ctrl() and key:shift()
    and not key:alt() and not key:super()
  if not shortcut then
    if key.keycode < 0xFFE1 or key.keycode > 0xFFEE then
      for k in pairs(pressed) do pressed[k] = nil end
    end
    return kNoop
  end
  if pressed[letter] then return kAccepted end

  local input = context.input or ""
  -- Ctrl+Shift+E 再按一次退出英文筛选，同时把隐藏前缀还原为原编码。
  if letter == "e" and (context:get_property("tab_mode") or "") == "english"
      and input:sub(1, 1) == "E" and enabled(env, letter) then
    pressed[letter] = true
    context:clear()
    context:push_input(input:sub(2))
    clear_mode_state(context)
    return kAccepted
  end
  local raw_input = source_input(context)
  if context:get_option("ascii_mode") or not context:is_composing()
      or not raw_input or not raw_input:match("^[a-z]+$")
      or not enabled(env, letter) then
    return kNoop
  end

  local mode = modes[letter]
  pressed[letter] = true
  context:clear()
  context:push_input(mode.prefix .. raw_input)
  context:set_property("tab_mode", mode.mode)
  context:set_property("tab_mode_display", mode.display)
  context:set_property("tab_mode_prefix", mode.prefix)
  if context.set_option then context:set_option("vertical_layout", not mode.horizontal) end
  context:set_property("candidate_select_keys", "")
  return kAccepted
end

return M
