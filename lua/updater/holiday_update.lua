-- 兼容入口：日期计算模块无需感知通用更新管理器的内部结构。
local manager = require("update_manager")
local M = {}
function M.check_and_apply_tmp() return manager.check_and_apply("holidays") end
function M.should_check() return manager.should_check("holidays") end
function M.trigger_update(force) return manager.trigger("holidays", force == true) end
return M
