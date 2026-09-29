--[[
  anyou_processor.lua
  民事案由筛选模式候选详情与按键管理处理器
  1. 将当前高亮三级案由对应的四级子案由注入 candidate_detail 侧窗。
  2. 离开 A 模式（上屏或取消）时清理侧窗详情。
  3. 候选窗口动态横/竖排布局由 layout_manager 统一管理。
  4. 保留主键盘数字键 1~9 与空格键正常用于案由选词上屏，字母键正常输入用于首拼筛选。
--]]

local kNoop = 2
local anyou_data = require("anyou_data")
local DETAIL_OWNER = "anyou"
local DETAIL_WIDTH_PROPERTY = "candidate_detail_width"

local function is_anyou_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  if tab_mode ~= "anyou" then
    return false
  end
  local input = context.input or ""
  return input:match("^A") ~= nil
end

local function configured_detail_width(env)
  local config = env.engine and env.engine.schema and env.engine.schema.config
  local width = config and config:get_int("anyou/detail_width") or 0
  return width > 0 and tostring(width) or ""
end

local function clear_owned_detail(context)
  if (context:get_property("candidate_detail_owner") or "") == DETAIL_OWNER then
    context:set_property("candidate_detail", "")
    context:set_property("candidate_detail_owner", "")
    context:set_property(DETAIL_WIDTH_PROPERTY, "")
  end
end

local function sync_detail(context, env)
  local cur_detail = context:get_property("candidate_detail") or ""
  if not is_anyou_context(context) then
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

  local detail = anyou_data.get_detail(cand.text) or ""
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

  env.anyou_update_connection = context.update_notifier:connect(function(ctx)
    sync_detail(ctx, env)
  end)

  env.anyou_select_connection = context.select_notifier:connect(function(ctx)
    sync_detail(ctx, env)
  end)
end

function processor.fini(env)
  if env.anyou_update_connection then
    env.anyou_update_connection:disconnect()
    env.anyou_update_connection = nil
  end
  if env.anyou_select_connection then
    env.anyou_select_connection:disconnect()
    env.anyou_select_connection = nil
  end

  local context = env.engine and env.engine.context
  if context then
    clear_owned_detail(context)
  end
end

function processor.func(key, env)
  -- 案由模式下，字母作为首拼输入，数字/空格/回车由 Rime 原生处理器正常选词上屏
  return kNoop
end

return processor
