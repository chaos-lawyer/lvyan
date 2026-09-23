local lpr_data = require("lpr_data")
local lpr_source = require("lpr_source")
local H = {}

local function tmp_path() return lpr_data.get_file_path("lpr_download.tmp") end

local function target_month(now)
  local year, month = now.year, now.month
  if now.day < 20 then
    month = month - 1
    if month == 0 then year, month = year - 1, 12 end
  end
  return string.format("%04d-%02d", year, month)
end

function H.should_check(job)
  local target = target_month(os.date("*t"))
  local data = lpr_data.load_data()
  if not data or not data.records or not data.records[1] then return true, target end
  return data.records[1].date:sub(1, 7) < target, target
end

function H.force_target(job) return target_month(os.date("*t")) end

function H.build_request(job, target)
  return { url = job.url or lpr_source.PRIMARY_URL, tmp_path = tmp_path() }
end

function H.check_and_apply(job)
  local path = tmp_path()
  local f = io.open(path, "r"); if not f then return false, false end
  local content = f:read("*a"); f:close()
  local ok, record = pcall(lpr_source.parse_response, content or "")
  if not ok or not record then os.remove(path); return false, true end
  local loaded = lpr_data.load_data(true)
  if not loaded or not loaded.records then os.remove(path); return false, true end
  -- 在副本上合并，写盘失败时不污染 lpr_data 的内存缓存。
  local data = { updated_at = loaded.updated_at, last_check = os.date("%Y-%m-%d"), records = {} }
  for _, item in ipairs(loaded.records) do
    table.insert(data.records, { date = item.date, lpr1y = item.lpr1y, lpr5y = item.lpr5y })
  end
  local latest = data.records[1]
  if not latest or record.date > latest.date then
    table.insert(data.records, 1, record); data.updated_at = record.date
  elseif record.date == latest.date then
    latest.lpr1y, latest.lpr5y = record.lpr1y, record.lpr5y
  end
  local saved = lpr_data.save_data(data)
  os.remove(path)
  return saved == true, true
end

return H
