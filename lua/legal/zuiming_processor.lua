--[[
  zuiming_processor.lua
  刑法罪名筛选模式动态布局、候选详情与按键管理处理器
  1. 监听上下文变化，进入 Z 模式（输入 ^Z）时自动开启 vertical_layout，使候选窗竖排显示。
  2. 离开 Z 模式（上屏或取消）时自动复原为横排。
  3. 将当前高亮罪名对应的刑法条文注入 candidate_detail 侧窗。
  4. 保留主键盘数字键 1~9 与空格键正常用于罪名选词上屏，字母键正常输入用于首拼筛选。
--]]

local kAccepted = 1
local kNoop = 2

local layout_option = "vertical_layout"
local zuiming_detail_data = require("zuiming_detail_data")
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

-- 检查是否有其他需要保持竖排的模式正在运行（如民事案由 A、LPR、日期 R、V 模式）
local function is_other_vertical_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  return (tab_mode == "anyou" or tab_mode == "fayuan" or tab_mode == "falv" or tab_mode == "legal_search" or tab_mode == "lpr" or tab_mode == "r" or tab_mode == "rf" or tab_mode == "v" or tab_mode == "fenshu")
end

local is_syncing = false

local function sync_detail(context)
  local cur_detail = context:get_property("candidate_detail") or ""
  if not is_zuiming_context(context) then
    if (context:get_property("candidate_detail_owner") or "") == DETAIL_OWNER then
      context:set_property("candidate_detail", "")
      context:set_property("candidate_detail_owner", "")
    end
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

  local detail = cand and zuiming_detail_data.get_detail(cand.text) or ""
  if cur_detail ~= detail then
    context:set_property("candidate_detail", detail)
  end
  if detail ~= "" then
    context:set_property("candidate_detail_owner", DETAIL_OWNER)
  else
    context:set_property("candidate_detail", "")
    context:set_property("candidate_detail_owner", "")
  end
end

local function sync_mode(context)
  if is_syncing then return end
  is_syncing = true

  local in_zuiming = is_zuiming_context(context)
  local in_other = is_other_vertical_context(context)
  local should_be_vertical = in_zuiming or in_other

  if context:get_option(layout_option) ~= should_be_vertical then
    context:set_option(layout_option, should_be_vertical)
  end

  sync_detail(context)

  is_syncing = false
end

local processor = {}

function processor.init(env)
  local context = env.engine.context
  sync_mode(context)
  env.zuiming_layout_connection = context.update_notifier:connect(function(ctx)
    sync_mode(ctx)
  end)
  env.zuiming_select_connection = context.select_notifier:connect(function(ctx)
    sync_detail(ctx)
  end)
end

function processor.func(key_event, env)
  local context = env.engine.context

  if not is_zuiming_context(context) then
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
  if env.zuiming_layout_connection then
    env.zuiming_layout_connection:disconnect()
    env.zuiming_layout_connection = nil
  end
  if env.zuiming_select_connection then
    env.zuiming_select_connection:disconnect()
    env.zuiming_select_connection = nil
  end

  local context = env.engine and env.engine.context
  if context and (context:get_property("candidate_detail_owner") or "") == DETAIL_OWNER then
    context:set_property("candidate_detail", "")
    context:set_property("candidate_detail_owner", "")
  end
end

return processor
