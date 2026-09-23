--[[
  lpr_select_processor.lua
  在 LPR 模式下，支持 a/b/c/d/e（及 A/B/C/D/E）作为选择键，
  对应选择当前页的第 1, 2, 3, 4, 5 个候选。
--]]

local kAccepted = 1
local kNoop = 2

local key_map = {
  a = 1, b = 2, c = 3, d = 4, e = 5,
  A = 1, B = 2, C = 3, D = 4, E = 5,
}

local layout_option = "vertical_layout"

local function is_vertical_mode_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  return (tab_mode == "lpr" or tab_mode == "r" or tab_mode == "rf" or tab_mode == "v"
    or tab_mode == "anyou" or tab_mode == "zuiming" or tab_mode == "fayuan" or tab_mode == "falv" or tab_mode == "fenshu")
end

local function is_letter_select_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  return (tab_mode == "lpr" or tab_mode == "r" or tab_mode == "rf" or tab_mode == "v" or tab_mode == "fenshu")
end

local function is_lpr_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  return (tab_mode == "lpr" or tab_mode == "v" or tab_mode == "fenshu")
end

local select_keys_property = "candidate_select_keys"

local function is_law_number_context(context)
  return context:is_composing() and (context.input or ""):match("^[Dd]%d+$") ~= nil
end

local is_syncing = false

-- 候选菜单进入/离开 LPR 或日期模式时同步动态布局 option 与动态候选选择键。
-- 仅在状态发生变化时写入，避免再次触发 update_notifier 后形成循环。
local function sync_mode(context)
  if is_syncing then return end
  is_syncing = true

  local should_be_vertical = is_vertical_mode_context(context)
  if context:get_option(layout_option) ~= should_be_vertical then
    context:set_option(layout_option, should_be_vertical)
  end

  local in_lpr = is_lpr_context(context)
  local cur_keys = context:get_property(select_keys_property) or ""
  if in_lpr then
    if cur_keys ~= "abcde" then
      context:set_property(select_keys_property, "abcde")
    end
  else
    if cur_keys == "abcde" and not is_letter_select_context(context) and not is_law_number_context(context) then
      context:set_property(select_keys_property, "")
    end
  end

  is_syncing = false
end

local processor = {}

function processor.init(env)
  local context = env.engine.context
  sync_mode(context)
  env.lpr_layout_connection = context.update_notifier:connect(function(ctx)
    sync_mode(ctx)
  end)
end

function processor.fini(env)
  if env.lpr_layout_connection then
    env.lpr_layout_connection:disconnect()
    env.lpr_layout_connection = nil
  end

  local context = env.engine and env.engine.context
  if context then
    if context:get_option(layout_option) then
      context:set_option(layout_option, false)
    end
    if context:get_property(select_keys_property) == "abcde" then
      context:set_property(select_keys_property, "")
    end
  end
end

local op_key_map = {
  ["plus"] = "+",
  ["+"] = "+",
  ["KP_Add"] = "+",
  ["minus"] = "-",
  ["-"] = "-",
  ["KP_Subtract"] = "-",
  ["asterisk"] = "*",
  ["*"] = "*",
  ["KP_Multiply"] = "*",
  ["slash"] = "/",
  ["/"] = "/",
  ["KP_Divide"] = "/",
  ["period"] = ".",
  ["."] = ".",
  ["KP_Decimal"] = ".",
  ["percent"] = "%",
  ["%"] = "%",
  ["dollar"] = "$",
  ["$"] = "$",
  ["Shift+dollar"] = "$",
  ["Shift+4"] = "$",
  ["yen"] = "$",
  ["¥"] = "$",
  ["parenleft"] = "(",
  ["("] = "(",
  ["parenright"] = ")",
  [")"] = ")",
  ["w"] = "w",
  ["W"] = "w",
  ["y"] = "y",
  ["Y"] = "y",
}

function processor.func(key, env)
  if key:release() then return kNoop end
  if key:ctrl() or key:alt() or key:super() then return kNoop end

  local context = env.engine.context
  if not is_lpr_context(context) then
    return kNoop
  end

  local key_repr = key:repr()

  -- 1. 拦截运算符、小数点、括号与金额符号，防止被 punctuator 转换为中文标点或直接上屏
  local op_char = op_key_map[key_repr]
  if not op_char and (key.keycode == 0x24 or key.keycode == 0xa5 or (key:shift() and key_repr == "4")) then
    op_char = "$"
  end
  if op_char then
    if context.push_input then
      context:push_input(op_char)
    else
      context.input = (context.input or "") .. op_char
    end
    return kAccepted
  end

  local sel_num = key_map[key_repr]
  if not sel_num then
    return kNoop
  end

  local composition = context.composition
  if not composition or composition:empty() then
    return kNoop
  end

  local seg = composition:back()
  local menu = seg and seg.menu
  if not menu or menu:empty() or menu:candidate_count() == 0 then
    return kNoop
  end

  local page_sz = 5
  if env.engine.schema and env.engine.schema.config then
    page_sz = env.engine.schema.config:get_int("menu/page_size") or 5
  end

  local sel_index = seg.selected_index or 0
  local page_start = math.floor(sel_index / page_sz) * page_sz
  local index = page_start + (sel_num - 1)

  if index < menu:candidate_count() then
    if context:select(index) then
      return kAccepted
    end

    local cand = menu:get_candidate_at(index)
    if cand then
      env.engine:commit_text(cand.text)
      context:clear()
      return kAccepted
    end
  end

  return kNoop
end

return processor
