-- d/D + 纯数字模式使用 a/b/c/d/e 选择当前页第 1～5 个候选。

local kAccepted = 1
local kNoop = 2

local key_map = {
  a = 1, b = 2, c = 3, d = 4, e = 5,
  A = 1, B = 2, C = 3, D = 4, E = 5,
}

local select_keys_property = "candidate_select_keys"

local function is_law_number_context(context)
  return context:is_composing() and (context.input or ""):match("^[Dd]%d+$") ~= nil
end

local function another_letter_select_mode(context)
  local tab_mode = context:get_property("tab_mode") or ""
  return tab_mode == "lpr" or tab_mode == "r" or tab_mode == "rf" or tab_mode == "v" or tab_mode == "fenshu"
end

local syncing = false

local function sync_select_keys(context)
  if syncing then return end
  syncing = true

  local current = context:get_property(select_keys_property) or ""
  if is_law_number_context(context) then
    if current ~= "abcde" then
      context:set_property(select_keys_property, "abcde")
    end
  elseif current == "abcde" and not another_letter_select_mode(context) then
    context:set_property(select_keys_property, "")
  end

  syncing = false
end

local processor = {}

function processor.init(env)
  local context = env.engine.context
  env.page_size = 5
  if env.engine.schema and env.engine.schema.config then
    env.page_size = env.engine.schema.config:get_int("menu/page_size") or 5
  end
  sync_select_keys(context)
  env.law_select_connection = context.update_notifier:connect(function(ctx)
    sync_select_keys(ctx)
  end)
end

function processor.fini(env)
  if env.law_select_connection then
    env.law_select_connection:disconnect()
    env.law_select_connection = nil
  end

  local context = env.engine and env.engine.context
  if context and context:get_property(select_keys_property) == "abcde"
    and not another_letter_select_mode(context) then
    context:set_property(select_keys_property, "")
  end
end

function processor.func(key, env)
  if key:release() or key:ctrl() or key:alt() or key:super() then return kNoop end

  local context = env.engine.context
  if not is_law_number_context(context) or not context:has_menu() then return kNoop end

  local choice = key_map[key:repr()]
  if not choice then return kNoop end

  local composition = context.composition
  if not composition or composition:empty() then return kNoop end
  local segment = composition:back()
  local menu = segment and segment.menu
  if not menu or menu:empty() then return kNoop end

  local page_size = env.page_size or 5
  local page_start = math.floor((segment.selected_index or 0) / page_size) * page_size
  local index = page_start + choice - 1
  if index >= menu:candidate_count() then return kNoop end

  if context:select(index) then return kAccepted end
  local candidate = menu:get_candidate_at(index)
  if candidate then
    env.engine:commit_text(candidate.text)
    context:clear()
    return kAccepted
  end
  return kNoop
end

return processor
