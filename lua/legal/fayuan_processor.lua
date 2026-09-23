--[[
  fayuan_processor.lua
  全国人民法院筛选模式动态布局与按键管理处理器
  1. 监听上下文变化，进入 F 模式（输入 ^F 且 tab_mode == "fayuan"）时自动开启 vertical_layout，使候选窗竖排显示。
  2. 离开 F 模式（上屏或取消）时自动复原为横排。
  3. 保留主键盘数字键 1~9 与空格键正常用于法院选词上屏，字母键正常输入用于首拼筛选。
--]]

local kAccepted = 1
local kNoop = 2

local layout_option = "vertical_layout"

local function is_fayuan_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  if tab_mode ~= "fayuan" then
    return false
  end
  local input = context.input or ""
  return input:match("^F") ~= nil
end

-- 检查是否有其他需要保持竖排的模式正在运行（如民事案由 A、刑法罪名 Z、LPR、日期 R、V 模式）
local function is_other_vertical_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  return (tab_mode == "anyou" or tab_mode == "zuiming" or tab_mode == "falv" or tab_mode == "legal_search" or tab_mode == "lpr" or tab_mode == "r" or tab_mode == "rf" or tab_mode == "v" or tab_mode == "fenshu")
end

local is_syncing = false

local function sync_mode(context)
  if is_syncing then return end
  is_syncing = true

  local in_fayuan = is_fayuan_context(context)
  local in_other = is_other_vertical_context(context)
  local should_be_vertical = in_fayuan or in_other

  if context:get_option(layout_option) ~= should_be_vertical then
    context:set_option(layout_option, should_be_vertical)
  end

  is_syncing = false
end

local processor = {}

function processor.init(env)
  local context = env.engine.context
  sync_mode(context)
  env.fayuan_layout_connection = context.update_notifier:connect(function(ctx)
    sync_mode(ctx)
  end)
end

function processor.func(key_event, env)
  local context = env.engine.context

  if not is_fayuan_context(context) then
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
  if env.fayuan_layout_connection then
    env.fayuan_layout_connection:disconnect()
    env.fayuan_layout_connection = nil
  end
end

return processor
