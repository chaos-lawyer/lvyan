-- rime.lua
-- Rime Lua 全局初始化入口与模块自动寻址配置
-- 自动将 lua 各领域子目录追加至 package.path，支持优雅模块化与平滑寻址

local user_dir = (_G.rime_api and _G.rime_api.get_user_data_dir and _G.rime_api.get_user_data_dir()) or ""
local sep = (package.config and package.config:sub(1, 1)) or "/"
local subdirs = { "legal", "name", "tools", "filters", "updater", "core", "llm" }

for _, dir in ipairs(subdirs) do
  if user_dir ~= "" then
    package.path = package.path .. ";" .. user_dir .. sep .. "lua" .. sep .. dir .. sep .. "?.lua"
    package.path = package.path .. ";" .. user_dir .. sep .. "lua" .. sep .. dir .. sep .. "?/init.lua"
  end
  package.path = package.path .. ";lua" .. sep .. dir .. sep .. "?.lua"
  package.path = package.path .. ";lua" .. sep .. dir .. sep .. "?/init.lua"
  package.path = package.path .. ";Rime" .. sep .. "lua" .. sep .. dir .. sep .. "?.lua"
  package.path = package.path .. ";Rime" .. sep .. "lua" .. sep .. dir .. sep .. "?/init.lua"
end
