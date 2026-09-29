-- 在普通拼音/双拼编码过程中，用 Ctrl+Shift+A/Y/F/Z/E/B/N 将当前编码带入筛选模式。
-- 已进入某个筛选模式（如通讯录模式）时，同一快捷键可以直接切换到另一模式，并保留原查询编码。
local layout_manager = require("layout_manager")

local M = {}
local kAccepted, kNoop = 1, 2

local modes = {
  a = { prefix = "A", mode = "anyou", display = "a" },
  y = { prefix = "F", mode = "fayuan", display = "y" },
  f = { prefix = "G", mode = "falv", display = "f" },
  z = { prefix = "Z", mode = "zuiming", display = "z" },
  e = { prefix = "Oe", mode = "english", display = "e", config_key = "english", horizontal = true },
  b = { prefix = "B", mode = "emoji", display = "b", horizontal = true },
  n = { prefix = "N", mode = "contacts", display = "n", config_key = "contacts" },
}

local auxiliary_modes = {
  { prefix = "L", mode = "lpr" },
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
  context:set_property("candidate_select_keys", "")
  layout_manager.sync(context)
end

local function source_input(context)
  local input = context.input or ""
  local active_mode = context:get_property("tab_mode") or ""
  if active_mode == "" then return input end

  -- 仅从本处理器创建的模式中剥离隐藏前缀，避免接管无关的 composing 状态。
  for _, mode in pairs(modes) do
    if mode.mode == active_mode and input:sub(1, #mode.prefix) == mode.prefix then
      return input:sub(#mode.prefix + 1)
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
  -- English 与 Contacts 模式具有引导前缀；显式清空才能让 Escape 与其他模式
  -- 一样一次取消整段编码，而不是只撤回末尾字符。
  local cur_mode = context:get_property("tab_mode") or ""
  if key:repr() == "Escape" and (cur_mode == "english" or cur_mode == "contacts") then
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
  -- Ctrl+Shift+E 或 Ctrl+Shift+N 再按一次退出对应筛选，同时把隐藏前缀还原为原编码。
  if letter == "e" and cur_mode == "english"
      and input:sub(1, #modes.e.prefix) == modes.e.prefix and enabled(env, letter) then
    pressed[letter] = true
    context:clear()
    context:push_input(input:sub(#modes.e.prefix + 1))
    clear_mode_state(context)
    return kAccepted
  end
  if letter == "n" and cur_mode == "contacts"
      and input:sub(1, 1) == "N" and enabled(env, letter) then
    pressed[letter] = true
    context:clear()
    context:push_input(input:sub(2))
    clear_mode_state(context)
    return kAccepted
  end
  local raw_input = source_input(context)
  if context:get_option("ascii_mode") or not context:is_composing()
      or not raw_input or not enabled(env, letter) then
    return kNoop
  end

  -- 普通输入状态下，必须有拼音字母才带入模式；
  -- 已在筛选模式（如通讯录模式）下，允许空编码或小写拼音直接切换到其他模式。
  if cur_mode == "" then
    if not raw_input:match("^[a-z]+$") then
      return kNoop
    end
  else
    if not raw_input:match("^[a-z]*$") then
      return kNoop
    end
  end

  local mode = modes[letter]
  pressed[letter] = true
  context:clear()
  context:push_input(mode.prefix .. raw_input)
  context:set_property("tab_mode", mode.mode)
  context:set_property("tab_mode_display", mode.display)
  context:set_property("tab_mode_prefix", mode.prefix)
  context:set_property("candidate_select_keys", "")
  if context:get_option("name_mode") then
    context:set_option("name_mode", false)
  end
  layout_manager.sync(context)
  return kAccepted
end

return M
