--[[
  name_filter.lua
  人名模式过滤器：
  1. 普通模式 (name_mode = false)：完全不介入，原样放行所有普通候选。
  2. 人名模式 (name_mode = true)：只放行 name_translator 标记的人名候选 (type == "name")，
     彻底过滤普通词语（如“为了”、“网络”等）。
--]]

local M = {}

function M.init(env)
end

function M.func(input, env)
  local context = env.engine.context
  if not context:get_option("name_mode") then
    -- 普通模式完全不介入，原样放行所有候选
    for cand in input:iter() do
      yield(cand)
    end
    return
  end

  -- 人名模式：仅放行 name_translator 产生的人名候选 (cand.type == "name")
  for cand in input:iter() do
    if cand.type == "name" then
      yield(cand)
    end
  end
end

return M
