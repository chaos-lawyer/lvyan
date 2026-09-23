--[[
  name_mode.lua
  人名模式聚合入口模块，遵循更新方案结构建议。
--]]

local name_utils = require("name_utils")
local name_mode_hotkey = require("name_mode_hotkey")
local name_translator = require("name_translator")
local name_filter = require("name_filter")

return {
  utils = name_utils,
  hotkey = name_mode_hotkey,
  translator = name_translator,
  filter = name_filter,
}
