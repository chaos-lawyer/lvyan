--[[
  falv_processor.lua
  国家法律文件检索模式动态布局与候选详情面板联动处理器
  1. 监听上下文变化，进入 G 模式（输入 ^G 且 tab_mode == "falv"）时自动开启 vertical_layout，使候选窗竖排显示。
  2. 离开 G 模式（上屏或取消）时自动复原为横排。
  3. 监听候选高亮与选择变更（update_notifier 与 select_notifier），实时将当前候选的详情注入 candidate_detail 属性。
  4. 离开 G 模式或当前词条无详情时，立即清除 candidate_detail 属性，使 Weasel 详情面板静默关闭。
  5. 保留主键盘数字键 1~9 与空格键正常用于选词上屏，字母键正常用于输入检索。
--]]

local kAccepted = 1
local kNoop = 2

local layout_option = "vertical_layout"
local falv_data = require("falv_data")
local DETAIL_OWNER = "falv"
local DETAIL_WIDTH_PROPERTY = "candidate_detail_width"

local function configured_detail_width(env)
  local config = env.engine and env.engine.schema and env.engine.schema.config
  local width = config and config:get_int("falv/detail_width") or 0
  return width > 0 and tostring(width) or ""
end

local function clear_owned_detail(context)
  if (context:get_property("candidate_detail_owner") or "") == DETAIL_OWNER then
    context:set_property("candidate_detail", "")
    context:set_property("candidate_detail_owner", "")
    context:set_property(DETAIL_WIDTH_PROPERTY, "")
  end
end

local function is_falv_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  if tab_mode ~= "falv" then
    return false
  end
  local input = context.input or ""
  return input:match("^G") ~= nil
end

-- 检查是否有其他需要保持竖排的模式正在运行（如民事案由 A、刑法罪名 Z、法院 F、LPR、日期 R、V 模式）
local function is_other_vertical_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  return (tab_mode == "anyou" or tab_mode == "zuiming" or tab_mode == "fayuan" or tab_mode == "legal_search" or tab_mode == "lpr" or tab_mode == "r" or tab_mode == "rf" or tab_mode == "v" or tab_mode == "fenshu")
end

local is_syncing = false

local function sync_detail(context, env)
  local cur_detail = context:get_property("candidate_detail") or ""
  if not is_falv_context(context) then
    clear_owned_detail(context)
    return
  end

  local cand = context.get_selected_candidate and context:get_selected_candidate()
  if not cand then
    local composition = context.composition
    if composition and not composition:empty() then
      local seg = composition:back()
      if seg then
        cand = seg:get_selected_candidate()
      end
    end
  end

  if not cand then
    clear_owned_detail(context)
    return
  end

  local detail = falv_data.get_detail(cand.text) or ""
  if cur_detail ~= detail then
    context:set_property("candidate_detail", detail)
  end
  if detail ~= "" then
    context:set_property("candidate_detail_owner", DETAIL_OWNER)
    context:set_property(DETAIL_WIDTH_PROPERTY, configured_detail_width(env))
  else
    clear_owned_detail(context)
  end
end

local function sync_mode(context, env)
  if is_syncing then return end
  is_syncing = true

  local in_falv = is_falv_context(context)
  local in_other = is_other_vertical_context(context)
  local should_be_vertical = in_falv or in_other

  if context:get_option(layout_option) ~= should_be_vertical then
    context:set_option(layout_option, should_be_vertical)
  end

  sync_detail(context, env)

  is_syncing = false
end

local processor = {}

function processor.init(env)
  local context = env.engine.context
  sync_mode(context, env)

  env.falv_layout_connection = context.update_notifier:connect(function(ctx)
    sync_mode(ctx, env)
  end)

  env.falv_select_connection = context.select_notifier:connect(function(ctx)
    sync_detail(ctx, env)
  end)
end

function processor.func(key_event, env)
  local context = env.engine.context

  if not is_falv_context(context) then
    return kNoop
  end

  -- 数字键 1~9 以及空格键放行给 selector 处理上屏
  local ch = key_event.keycode
  if (ch >= 49 and ch <= 57) or ch == 32 then
    return kNoop
  end

  return kNoop
end

function processor.fini(env)
  if env.falv_layout_connection then
    env.falv_layout_connection:disconnect()
    env.falv_layout_connection = nil
  end
  if env.falv_select_connection then
    env.falv_select_connection:disconnect()
    env.falv_select_connection = nil
  end

  local context = env.engine and env.engine.context
  if context then
    if (context:get_property("candidate_detail_owner") or "") == DETAIL_OWNER then
      context:set_property("candidate_detail", "")
      context:set_property("candidate_detail_owner", "")
      context:set_property(DETAIL_WIDTH_PROPERTY, "")
    end
  end
end

return processor
