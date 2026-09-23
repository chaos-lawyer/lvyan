local json = require("lpr_json")
local H = {}

local function base_dir()
  if _G.rime_api and _G.rime_api.get_user_data_dir then return _G.rime_api.get_user_data_dir() end
  local f = io.open("lua/holidays.lua", "r")
  if f then f:close(); return "." end
  return "Rime"
end

local function lua_path(name)
  local sep = package.config:sub(1, 1) or "/"
  return base_dir() .. sep .. "lua" .. sep .. name
end

local function holidays()
  local ok, value = pcall(require, "holidays")
  return (ok and type(value) == "table") and value or nil
end

local function window_open(job, now)
  local month, day = tonumber(job.start_month) or 11, tonumber(job.start_day) or 20
  return now.month > month or (now.month == month and now.day >= day)
end

local function target_year(job, now)
  local value = holidays()
  local years = value and value.years or {}
  if not years[now.year] then return now.year end
  if window_open(job, now) and not years[now.year + 1] then return now.year + 1 end
  return nil
end

function H.should_check(job)
  local target = target_year(job, os.date("*t"))
  return target ~= nil, target
end

function H.force_target(job)
  local now = os.date("*t")
  return target_year(job, now) or now.year + 1
end

function H.build_request(job, target)
  local template = job.url_template or "https://fastly.jsdelivr.net/gh/NateScarlet/holiday-cn@master/{year}.json"
  return { url = template:gsub("{year}", tostring(target)), tmp_path = lua_path("holidays_download.tmp") }
end

local function valid(job, data)
  if type(data) ~= "table" or not tonumber(data.year) then return false end
  if type(data.days) ~= "table" or #data.days == 0 then return false end
  return job.require_papers == false or (type(data.papers) == "table" and #data.papers > 0)
end

local function render(value)
  local lines = { "--[[", "  holidays.lua", "  中国法定节假日与调休补班本地数据", "  自动更新入库于 " .. os.date("%Y-%m-%d %H:%M:%S"), "  true  = 调休补班工作日 (周末变工作日)", "  false = 法定节假日/调休放假 (工作日变休息日)", "  nil   = 按自然周判断 (周一至周五为工作日，周六周日为休息日)", "--]]", "", "local M = {}", "", "M.years = {" }
  local years = {}; for year in pairs(value.years) do table.insert(years, year) end; table.sort(years)
  for _, year in ipairs(years) do table.insert(lines, string.format("    [%d] = true,", year)) end
  table.insert(lines, "}"); table.insert(lines, ""); table.insert(lines, "M.days = {")
  local days = {}; for date in pairs(value.days) do table.insert(days, date) end; table.sort(days)
  for _, date in ipairs(days) do table.insert(lines, string.format('    ["%s"] = %s,', date, value.days[date] and "true" or "false")) end
  table.insert(lines, "}"); table.insert(lines, ""); table.insert(lines, "return M"); table.insert(lines, "")
  return table.concat(lines, "\n")
end

function H.check_and_apply(job)
  local path = lua_path("holidays_download.tmp")
  local f = io.open(path, "r"); if not f then return false, false end
  local content = f:read("*a"); f:close()
  local ok, data = pcall(json.decode, content or "")
  if not ok or not valid(job, data) then os.remove(path); return false, true end
  local year, now = tonumber(data.year), os.date("*t")
  if year > now.year + 1 or (year == now.year + 1 and not window_open(job, now)) then os.remove(path); return false, true end
  local expected = target_year(job, now)
  if expected and year ~= expected then os.remove(path); return false, true end
  local loaded = holidays() or { years = {}, days = {} }
  if loaded.years and loaded.years[year] then os.remove(path); return true, true end
  -- 在副本上合并，写盘失败时不污染 package.loaded 中仍在使用的数据。
  local value = { years = {}, days = {} }
  for existing_year, present in pairs(loaded.years or {}) do value.years[existing_year] = present end
  for date, is_workday in pairs(loaded.days or {}) do value.days[date] = is_workday end
  local added = 0
  for _, item in ipairs(data.days) do
    if type(item.date) == "string" and item.date:match("^%d%d%d%d%-%d%d%-%d%d$") and item.isOffDay ~= nil then
      value.days[item.date] = not item.isOffDay; added = added + 1
    end
  end
  if added == 0 then os.remove(path); return false, true end
  value.years[year] = true
  local output, temp = lua_path("holidays.lua"), lua_path("holidays.lua.tmp")
  local out = io.open(temp, "w"); if not out then os.remove(path); return false, true end
  out:write(render(value)); out:flush(); out:close()
  if not os.rename(temp, output) then
    os.remove(output)
    if not os.rename(temp, output) then os.remove(temp); os.remove(path); return false, true end
  end
  package.loaded["holidays"] = value
  os.remove(path)
  return true, true
end

return H
