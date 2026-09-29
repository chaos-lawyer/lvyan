--[[
  zuiming_processor.lua
  刑法罪名筛选模式候选详情面板联动处理器
  1. 监听候选高亮与选择变更（update_notifier 与 select_notifier），实时将当前候选的罪名构成要件注入 candidate_detail 属性。
  2. 离开 Z 模式或当前词条无详情时，立即清除 candidate_detail 属性，使 Weasel 详情面板静默关闭。
  3. 候选窗口动态横/竖排布局由 layout_manager 统一管理。
  4. 保留主键盘数字键 1~9 与空格键正常用于罪名选词上屏，字母键正常输入用于首拼筛选。
--]]

local kNoop = 2
local zuiming_data = require("zuiming_data")
local DETAIL_OWNER = "zuiming"

local function is_zuiming_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  if tab_mode ~= "zuiming" then
    return false
  end
  local input = context.input or ""
  return input:match("^Z") ~= nil
end

local function clear_owned_detail(context)
  if (context:get_property("candidate_detail_owner") or "") == DETAIL_OWNER then
    context:set_property("candidate_detail", "")
    context:set_property("candidate_detail_owner", "")
  end
end

local function sync_detail(context)
  local cur_detail = context:get_property("candidate_detail") or ""
  if not is_zuiming_context(context) then
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

  local detail = zuiming_data.get_detail(cand.text) or ""
  if cur_detail ~= detail then
    context:set_property("candidate_detail", detail)
  end
  if detail ~= "" then
    context:set_property("candidate_detail_owner", DETAIL_OWNER)
  else
    clear_owned_detail(context)
  end
end

local processor = {}

function processor.init(env)
  local context = env.engine.context
  sync_detail(context)

  env.zuiming_update_connection = context.update_notifier:connect(function(ctx)
    sync_detail(ctx)
  end)
  env.zuiming_select_connection = context.select_notifier:connect(function(ctx)
    sync_detail(ctx)
  end)
end

function processor.func(key_event, env)
  return kNoop
end

function processor.fini(env)
  if env.zuiming_update_connection then
    env.zuiming_update_connection:disconnect()
    env.zuiming_update_connection = nil
  end
  if env.zuiming_select_connection then
    env.zuiming_select_connection:disconnect()
    env.zuiming_select_connection = nil
  end

  local context = env.engine and env.engine.context
  if context then
    clear_owned_detail(context)
  end
end

return processor
