--[[
  anyou_processor.lua
  民事案由筛选模式动态布局与按键管理处理器
  1. 监听上下文变化，进入 A 模式（输入 ^A）时自动开启 vertical_layout，使候选窗竖排显示。
  2. 离开 A 模式（上屏或取消）时自动复原为横排。
  3. 保留主键盘数字键 1~9 与空格键正常用于案由选词上屏，字母键正常输入用于首拼筛选。
--]]

local kAccepted = 1
local kNoop = 2

local layout_option = "vertical_layout"

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

-- 检查是否有其他需要保持竖排的模式正在运行（如 LPR、日期 R、V 模式）
local function is_other_vertical_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  return (tab_mode == "zuiming" or tab_mode == "fayuan" or tab_mode == "falv" or tab_mode == "legal_search" or tab_mode == "lpr" or tab_mode == "r" or tab_mode == "rf" or tab_mode == "v" or tab_mode == "fenshu")
end

local is_syncing = false

local function sync_mode(context)
  if is_syncing then return end
  is_syncing = true

  local in_anyou = is_anyou_context(context)
  local in_other = is_other_vertical_context(context)
  local should_be_vertical = in_anyou or in_other

  if context:get_option(layout_option) ~= should_be_vertical then
    context:set_option(layout_option, should_be_vertical)
  end

  is_syncing = false
end

local processor = {}

function processor.init(env)
  local context = env.engine.context
  sync_mode(context)
  env.anyou_layout_connection = context.update_notifier:connect(function(ctx)
    sync_mode(ctx)
  end)
end

function processor.fini(env)
  if env.anyou_layout_connection then
    env.anyou_layout_connection:disconnect()
    env.anyou_layout_connection = nil
  end

  local context = env.engine and env.engine.context
  if context then
    if not is_other_vertical_context(context) and context:get_option(layout_option) then
      context:set_option(layout_option, false)
    end
  end
end

function processor.func(key, env)
  -- 案由模式下，字母作为首拼输入，数字/空格/回车由 Rime 原生处理器正常选词上屏
  return kNoop
end

return processor
