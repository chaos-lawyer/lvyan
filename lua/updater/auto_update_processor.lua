--[[
  auto_update_processor.lua
  在输入法加载及日常普通输入期间维护 LPR 与节假日数据，避免更新依赖 L/R 模式。
  所有下载由通用更新管理器异步执行；本处理器只做低频触发，不消费按键。
--]]

local kNoop = 2
local manager

local function run_checks()
  if not manager then
    local ok, module = pcall(require, "update_manager")
    if ok then manager = module end
  end
  if manager then pcall(manager.run_all, false) end
end

local processor = {}

function processor.init(env)
  run_checks()
  local interval = manager and manager.get_poll_interval() or (8 * 60 * 60)
  env.next_auto_update_check = os.time() + interval
end

function processor.func(key, env)
  if not key:release() then
    local now = os.time()
    if now >= (env.next_auto_update_check or 0) then
      run_checks()
      local interval = manager and manager.get_poll_interval() or (8 * 60 * 60)
      env.next_auto_update_check = now + interval
    end
  end
  return kNoop
end

return processor
