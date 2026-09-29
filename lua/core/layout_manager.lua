--[[
  layout_manager.lua
  统一管理候选窗口的动态横/竖排布局（vertical_layout option）

  设计原则：单一事实来源（Single Source of Truth）
  1. 集中维护所有需要竖排的模式列表（VERTICAL_MODES）；
  2. 集中监听 context.update_notifier，根据当前 tab_mode 或输入状态统一计算并派发 vertical_layout；
  3. 各具体业务处理器（案由、罪名、法院、法律、LPR、日期、通讯录等）无需各自维护重复白名单，
     彻底杜绝跨处理器间的布局踩踏与竞争。
--]]

local M = {}
local kNoop = 2
local layout_option = "vertical_layout"

-- 统一维护所有启用竖排候选窗的模式白名单
M.VERTICAL_MODES = {
  anyou = true,        -- 民事案由 (A+Tab / Ctrl+Shift+A)
  zuiming = true,      -- 刑法罪名 (Z+Tab / Ctrl+Shift+Z)
  fayuan = true,       -- 全国人民法院 (Y+Tab / Ctrl+Shift+Y)
  falv = true,         -- 国家法律 (F+Tab / Ctrl+Shift+F)
  legal_search = true, -- 法律综合检索
  lpr = true,          -- LPR 利率检索 (l+Tab / Ctrl+Shift+L)
  r = true,            -- 日期时间
  rf = true,           -- 节假日
  v = true,            -- 快捷转换/计算
  fenshu = true,       -- 分数模式
  contacts = true,     -- 通讯录电话模式 (n+Tab / Ctrl+Shift+N)
}

-- 统一判定当前上下文是否应当显示为竖排
function M.is_vertical_context(context)
  if not context or not context:is_composing() then
    return false
  end

  local tab_mode = context:get_property("tab_mode") or ""
  if M.VERTICAL_MODES[tab_mode] then
    return true
  end

  -- 特殊标记：AI / LLM 模式激活期间竖排
  if context:get_property("llm_active") == "1" then
    return true
  end

  return false
end

local is_syncing = false

-- 统一同步布局 option，仅在状态变化时写入
function M.sync(context)
  if is_syncing or not context or not context.set_option then
    return
  end
  is_syncing = true

  local should_be_vertical = M.is_vertical_context(context)
  if context:get_option(layout_option) ~= should_be_vertical then
    context:set_option(layout_option, should_be_vertical)
  end

  is_syncing = false
end

-- 作为标准 Rime lua_processor
function M.init(env)
  local context = env.engine and env.engine.context
  if not context then return end

  M.sync(context)
  if context.update_notifier then
    env.layout_update_conn = context.update_notifier:connect(function(ctx)
      M.sync(ctx)
    end)
  end
end

function M.func(key, env)
  return kNoop
end

function M.fini(env)
  if env.layout_update_conn then
    env.layout_update_conn:disconnect()
    env.layout_update_conn = nil
  end
end

return M
