--[[
  fayuan_processor.lua
  全国人民法院筛选模式处理器
  1. 候选窗口动态横/竖排布局由 layout_manager 统一管理。
  2. 保留主键盘数字键 1~9 与空格键正常用于法院选词上屏，字母键正常输入用于首拼筛选。
--]]

local kNoop = 2

local processor = {}

function processor.init(env)
end

function processor.func(key_event, env)
  return kNoop
end

function processor.fini(env)
end

return processor
