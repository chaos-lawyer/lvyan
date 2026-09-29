--[[
  falv_processor.lua
  国家法律文件检索模式候选详情面板联动处理器
  1. 监听候选高亮与选择变更（update_notifier 与 select_notifier），实时将当前候选的详情注入 candidate_detail 属性。
  2. 离开 G 模式或当前词条无详情时，立即清除 candidate_detail 属性，使 Weasel 详情面板静默关闭。
  3. 候选窗口动态横/竖排布局由 layout_manager 统一管理。
  4. 保留主键盘数字键 1~9 与空格键正常用于选词上屏，字母键正常用于输入检索。
--]]

local kNoop = 2
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

local processor = {}

function processor.init(env)
  local context = env.engine.context
  sync_detail(context, env)

  env.falv_update_connection = context.update_notifier:connect(function(ctx)
    sync_detail(ctx, env)
  end)

  env.falv_select_connection = context.select_notifier:connect(function(ctx)
    sync_detail(ctx, env)
  end)
end

function processor.func(key_event, env)
  return kNoop
end

function processor.fini(env)
  if env.falv_update_connection then
    env.falv_update_connection:disconnect()
    env.falv_update_connection = nil
  end
  if env.falv_select_connection then
    env.falv_select_connection:disconnect()
    env.falv_select_connection = nil
  end

  local context = env.engine and env.engine.context
  if context then
    clear_owned_detail(context)
  end
end

return processor
