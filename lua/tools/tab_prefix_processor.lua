--[[
  tab_prefix_processor.lua
  功能模式前缀转换处理器
  功能模式默认仅通过「小写字母 + Tab」触发：
    b   + Tab -> Emoji 表情模式
    e   + Tab -> 英文前缀补全模式
    u   + Tab -> 拆字模式（亦支持大写 U 直接启动）
    r/rq + Tab -> 日期计算模式
    rf  + Tab -> 法定顺延模式（亦可在 r 模式后输入 f）
    lpr + Tab -> LPR 查询模式
    v   + Tab -> 数字转换 / 金额转换 / 计算器（亦支持大写 V 直接启动）
    a/ay + Tab -> 民事案由筛选模式
    z   + Tab -> 刑法罪名筛选模式
    f + Tab -> 法院/案由/罪名/法律综合检索；fy + Tab -> 法院专用检索
    l + Tab -> LPR 查询模式
  通过上下文属性 "tab_mode" 严格标记功能模式；
  除 v 模式和大写 U 拆字模式外，其他模式直接输入大写字母将不具备该标记，不会被误触发。
--]]

local kAccepted = 1
local kNoop = 2

local processor = {}

local is_switching = false

local function config_bool(config, path, fallback)
  local value = config:get_bool(path)
  if value == nil then return fallback end
  return value
end

local function mode_enabled(env, trigger)
  local config = env.engine.schema.config
  if not config_bool(config, "tab_mode_switches/enabled", true) then
    return false
  end
  return config_bool(config, "tab_mode_switches/" .. trigger, true)
end

-- 导出供独立回归测试使用；正常运行只通过 processor.func 调用。
processor.mode_enabled = mode_enabled

local function set_mode_display(context, env, typed_prefix, internal_prefix)
  local config = env.engine.schema.config
  local display = config:get_string("tab_mode_display/" .. typed_prefix)
    or typed_prefix
  context:set_property("tab_mode_display", display)
  context:set_property("tab_mode_prefix", internal_prefix)
end

local function reset_if_not_composing(context)
  if is_switching then return end
  if not context:is_composing() then
    if (context:get_property("tab_mode") or "") ~= "" then
      context:set_property("tab_mode", "")
      context:set_property("tab_mode_display", "")
      context:set_property("tab_mode_prefix", "")
    end
  end
end

function processor.init(env)
  local context = env.engine.context
  reset_if_not_composing(context)
  env.tab_mode_connection = context.update_notifier:connect(function(ctx)
    reset_if_not_composing(ctx)
  end)
end

function processor.fini(env)
  if env.tab_mode_connection then
    env.tab_mode_connection:disconnect()
    env.tab_mode_connection = nil
  end

  local context = env.engine and env.engine.context
  if context then
    context:set_property("tab_mode", "")
    context:set_property("tab_mode_display", "")
    context:set_property("tab_mode_prefix", "")
  end
end

function processor.func(key, env)
  if key:release() then return kNoop end
  local repr = key:repr()

  if key:ctrl() or key:alt() or key:super() then
    return kNoop
  end

  local context = env.engine.context
  local inp = context.input or ""

  -- 如果处于西文/英文模式，不拦截大写字母
  if context:get_option("ascii_mode") then
    return kNoop
  end

  -- 支持大写 V 直接启动 v 模式（数字转换 / 金额转换 / 计算器，仅在未组词或首字符时启动）
  local is_v = (repr == "V" or repr == "Shift+V" or repr == "Shift+v" or key.keycode == 86 or (key.keycode == 118 and key:shift()))
  if is_v and mode_enabled(env, "v") and
      (not context:is_composing() or inp == "") then
    is_switching = true
    context:clear()
    context:push_input("V")
    context:set_property("tab_mode", "v")
    set_mode_display(context, env, "V", "V")
    if context.set_option then context:set_option("vertical_layout", true) end
    context:set_property("candidate_select_keys", "abcde")
    is_switching = false
    return kAccepted
  end

  -- 支持大写 U 直接启动 u 模式（拆字模式，仅在未组词或首字符时启动）
  local is_u = (repr == "U" or repr == "Shift+U" or repr == "Shift+u" or key.keycode == 85 or (key.keycode == 117 and key:shift()))
  if is_u and mode_enabled(env, "u") and
      (not context:is_composing() or inp == "") then
    local config = env.engine.schema.config
    local prefix = config:get_string("radical_reverse_lookup/prefix") or "U"
    is_switching = true
    context:clear()
    context:push_input(prefix)
    context:set_property("tab_mode", "u")
    set_mode_display(context, env, "U", prefix)
    is_switching = false
    return kAccepted
  end

  if repr ~= "Tab" then
    return kNoop
  end

  -- u + Tab -> 拆字模式；兼容不同方案的 U / Uu 前缀。
  if inp == "u" and mode_enabled(env, "u") then
    local config = env.engine.schema.config
    local prefix = config:get_string("radical_reverse_lookup/prefix") or "U"
    is_switching = true
    context:clear()
    context:push_input(prefix)
    context:set_property("tab_mode", "u")
    set_mode_display(context, env, inp, prefix)
    is_switching = false
    return kAccepted
  end

  -- a / ay + Tab -> 案由筛选模式
  if (inp == "a" or inp == "ay") and mode_enabled(env, "a") then
    is_switching = true
    context:clear()
    context:push_input("A")
    context:set_property("tab_mode", "anyou")
    set_mode_display(context, env, inp, "A")
    if context.set_option then context:set_option("vertical_layout", true) end
    context:set_property("candidate_select_keys", "")
    is_switching = false
    return kAccepted
  end

  -- z + Tab -> 罪名筛选模式
  if inp == "z" and mode_enabled(env, "z") then
    is_switching = true
    context:clear()
    context:push_input("Z")
    context:set_property("tab_mode", "zuiming")
    set_mode_display(context, env, inp, "Z")
    if context.set_option then context:set_option("vertical_layout", true) end
    context:set_property("candidate_select_keys", "")
    is_switching = false
    return kAccepted
  end

  -- f + Tab -> 法院、案由、罪名、法律综合检索
  if inp == "f" and mode_enabled(env, "f") then
    is_switching = true
    context:clear()
    context:push_input("F")
    context:set_property("tab_mode", "legal_search")
    set_mode_display(context, env, inp, "F")
    if context.set_option then context:set_option("vertical_layout", true) end
    context:set_property("candidate_select_keys", "")
    is_switching = false
    return kAccepted
  end

  -- fy + Tab -> 兼容保留法院专用检索
  if inp == "fy" and mode_enabled(env, "f") then
    is_switching = true
    context:clear()
    context:push_input("F")
    context:set_property("tab_mode", "fayuan")
    set_mode_display(context, env, inp, "F")
    if context.set_option then context:set_option("vertical_layout", true) end
    context:set_property("candidate_select_keys", "")
    is_switching = false
    return kAccepted
  end

  -- l / lpr + Tab -> LPR 查询模式
  if (inp == "l" or inp == "lpr") and mode_enabled(env, "lpr") then
    is_switching = true
    context:clear()
    context:push_input("L")
    context:set_property("tab_mode", "lpr")
    set_mode_display(context, env, inp, "L")
    if context.set_option then context:set_option("vertical_layout", true) end
    context:set_property("candidate_select_keys", "abcde")
    is_switching = false
    return kAccepted
  end

  -- v + Tab -> V 模式（数字转换 / 金额转换 / 计算器）
  if inp == "v" and mode_enabled(env, "v") then
    is_switching = true
    context:clear()
    context:push_input("V")
    context:set_property("tab_mode", "v")
    set_mode_display(context, env, inp, "V")
    if context.set_option then context:set_option("vertical_layout", true) end
    context:set_property("candidate_select_keys", "abcde")
    is_switching = false
    return kAccepted
  end

  -- r / rq + Tab -> 日期计算模式
  if (inp == "r" or inp == "rq") and mode_enabled(env, "r") then
    is_switching = true
    context:clear()
    context:push_input("R")
    context:set_property("tab_mode", "r")
    set_mode_display(context, env, inp, "R")
    if context.set_option then context:set_option("vertical_layout", true) end
    context:set_property("candidate_select_keys", "abcde")
    is_switching = false
    return kAccepted
  end

  -- rf + Tab -> 法定顺延模式
  if inp == "rf" and mode_enabled(env, "rf") then
    is_switching = true
    context:clear()
    context:push_input("Rf")
    context:set_property("tab_mode", "rf")
    set_mode_display(context, env, inp, "Rf")
    if context.set_option then context:set_option("vertical_layout", true) end
    context:set_property("candidate_select_keys", "abcde")
    is_switching = false
    return kAccepted
  end

  -- ys / yu + Tab -> 文本份数模式（ys 全拼，yu 小鹤双拼）
  if (inp == "ys" or inp == "yu") and mode_enabled(env, "ys") then
    is_switching = true
    context:clear()
    context:push_input("Ys")
    context:set_property("tab_mode", "fenshu")
    set_mode_display(context, env, inp, "Ys")
    if context.set_option then context:set_option("vertical_layout", true) end
    context:set_property("candidate_select_keys", "abcde")
    is_switching = false
    return kAccepted
  end

  -- b + Tab -> Emoji 表情模式
  if inp == "b" and mode_enabled(env, "b") then
    is_switching = true
    context:clear()
    context:push_input("B")
    context:set_property("tab_mode", "emoji")
    set_mode_display(context, env, inp, "B")
    if context.set_option then context:set_option("vertical_layout", false) end
    context:set_property("candidate_select_keys", "")
    is_switching = false
    return kAccepted
  end

  -- e + Tab -> 英文前缀补全模式。
  if inp == "e" and mode_enabled(env, "english") then
    is_switching = true
    context:clear()
    context:push_input("E")
    context:set_property("tab_mode", "english")
    set_mode_display(context, env, inp, "E")
    if context.set_option then context:set_option("vertical_layout", false) end
    context:set_property("candidate_select_keys", "")
    is_switching = false
    return kAccepted
  end

  return kNoop
end

return processor
