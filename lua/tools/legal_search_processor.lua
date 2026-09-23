-- 综合法律检索：维护竖排布局，并将当前分类的详情同步到侧窗。
local M = {}
local OWNER = "legal_search"
local DETAIL_WIDTH_PROPERTY = "candidate_detail_width"
local kNoop = 2

local function current_detail(context, env)
  if not context:is_composing()
      or context:get_property("tab_mode") ~= "legal_search"
      or not (context.input or ""):match("^F") then
    return "", ""
  end

  local cand = context.get_selected_candidate and context:get_selected_candidate()
  if not cand then
    local composition = context.composition
    local seg = composition and not composition:empty() and composition:back()
    cand = seg and seg:get_selected_candidate() or nil
  end
  if not cand then return "", "" end

  local category = (cand.comment or ""):match("^〔([^〕]+)〕") or ""
  local detail
  if category == "罪名" then
    detail = require("zuiming_detail_data").get_detail(cand.text)
    if detail == "" then detail = cand.comment or "" end
  elseif category == "法律" then
    detail = require("falv_data").get_detail(cand.text)
  elseif category == "法院" then
    local region, level = (cand.comment or ""):match("^〔法院〕〔(.-)·(.-)〕")
    detail = "**人民法院**\n地区：" .. (region or "未标注") .. "\n审级：" .. (level or "未标注")
  elseif category == "案由" then
    local tag = (cand.comment or ""):match("^〔案由〕〔(.-)〕")
    detail = "**民事案由**\n" .. (tag or "未标注案由级别")
  else
    detail = cand.comment or ""
  end

  local width = ""
  if category == "法律" then
    local config = env.engine.schema.config
    local value = config and config:get_int("falv/detail_width") or 0
    if value and value > 0 then width = tostring(value) end
  end
  return detail or "", width
end

local function sync(context, env)
  local detail, width = current_detail(context, env)
  if detail ~= "" then
    context:set_property("candidate_detail", detail)
    context:set_property("candidate_detail_owner", OWNER)
    context:set_property(DETAIL_WIDTH_PROPERTY, width)
  elseif (context:get_property("candidate_detail_owner") or "") == OWNER then
    context:set_property("candidate_detail", "")
    context:set_property("candidate_detail_owner", "")
    context:set_property(DETAIL_WIDTH_PROPERTY, "")
  end

  local composing = context:is_composing()
  local tab_mode = context:get_property("tab_mode") or ""
  local vertical_modes = {
    anyou = true, zuiming = true, fayuan = true, falv = true,
    legal_search = true, lpr = true, r = true, rf = true, v = true, fenshu = true,
  }
  local should_be_vertical = composing and vertical_modes[tab_mode] == true
  if context:get_option("vertical_layout") ~= should_be_vertical then
    context:set_option("vertical_layout", should_be_vertical)
  end
end

function M.init(env)
  local context = env.engine.context
  env.update_connection = context.update_notifier:connect(function(ctx) sync(ctx, env) end)
  env.select_connection = context.select_notifier:connect(function(ctx) sync(ctx, env) end)
  sync(context, env)
end

function M.func(_, _) return kNoop end

function M.fini(env)
  if env.update_connection then env.update_connection:disconnect() end
  if env.select_connection then env.select_connection:disconnect() end
  local context = env.engine and env.engine.context
  if context and (context:get_property("candidate_detail_owner") or "") == OWNER then
    context:set_property("candidate_detail", "")
    context:set_property("candidate_detail_owner", "")
    context:set_property(DETAIL_WIDTH_PROPERTY, "")
  end
end

return M
