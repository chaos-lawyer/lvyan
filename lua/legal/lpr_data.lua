--[[
  lpr_data.lua
  LPR 数据管理层：安全读取、内存缓存、校验、历史查询与利息接口预留
--]]

local json = require("lpr_json")

local M = {}

local cached_data = nil
local last_loaded_time = 0

-- 获取用户数据根目录
function M.get_data_dir()
  local base_dir = "."
  if rime_api and rime_api.get_user_data_dir then
    base_dir = rime_api.get_user_data_dir()
  end
  return base_dir
end

function M.get_file_path(filename)
  local base = M.get_data_dir()
  local sep = package.config:sub(1, 1) or "/"
  local new_path = base .. sep .. "data" .. sep .. "legal" .. sep .. filename
  local f = io.open(new_path, "r")
  if f then
    f:close()
    return new_path
  end
  return base .. sep .. "legal_data" .. sep .. filename
end

-- 校验单条记录合法性
function M.validate_record(rec)
  if type(rec) ~= "table" then return false, "record is not a table" end
  if type(rec.date) ~= "string" or not rec.date:match("^%d%d%d%d%-%d%d%-%d%d$") then
    return false, "invalid date format"
  end
  local lpr1y = tonumber(rec.lpr1y)
  local lpr5y = tonumber(rec.lpr5y)
  if not lpr1y or lpr1y <= 0 or lpr1y > 30 then
    return false, "invalid lpr1y value"
  end
  if not lpr5y or lpr5y <= 0 or lpr5y > 30 then
    return false, "invalid lpr5y value"
  end
  return true
end

-- 校验整体数据结构合法性
function M.validate_data(data)
  if type(data) ~= "table" then return false, "data is not table" end
  if type(data.records) ~= "table" or #data.records == 0 then
    return false, "records is empty"
  end
  for i, rec in ipairs(data.records) do
    local ok, err = M.validate_record(rec)
    if not ok then
      return false, "record " .. i .. " invalid: " .. err
    end
  end
  return true
end

-- 读取并解析指定文件内容
local function read_json_file(filepath)
  local file = io.open(filepath, "r")
  if not file then return nil, "cannot open file" end
  local content = file:read("*a")
  file:close()
  if not content or #content == 0 then
    return nil, "file empty"
  end
  return json.decode(content)
end

-- 安全加载数据（优先 lpr.json，失败自动降级到 lpr.backup.json）
function M.load_data(force_reload)
  local now = os.time()
  if not force_reload and cached_data and (now - last_loaded_time < 30) then
    return cached_data
  end

  local primary_path = M.get_file_path("lpr.json")
  local backup_path = M.get_file_path("lpr.backup.json")

  local ok, data = pcall(read_json_file, primary_path)
  local is_valid, _ = M.validate_data(data)

  if not ok or not is_valid then
    -- 降级尝试 backup 文件
    local backup_ok, backup_data = pcall(read_json_file, backup_path)
    if backup_ok and M.validate_data(backup_data) then
      data = backup_data
    else
      -- 若 backup 依然失败，若已有 cache 则维持 cache
      if cached_data then return cached_data end
      return nil, "all lpr data sources corrupted"
    end
  end

  -- 确保 records 按照日期降序排序 (最新在前)
  table.sort(data.records, function(a, b)
    return a.date > b.date
  end)

  cached_data = data
  last_loaded_time = now
  return cached_data
end

-- 获取当前最新一期 LPR
function M.get_latest_lpr()
  local data = M.load_data()
  if not data or not data.records or #data.records == 0 then
    return nil
  end
  return data.records[1], data.updated_at, data.last_check
end

-- 格式化标准化日期字符串 YYYYMMDD -> YYYY-MM-DD
function M.normalize_date(date_str)
  if not date_str then return nil end
  date_str = tostring(date_str):gsub("[^%d%-]", "")
  if date_str:match("^%d%d%d%d%-%d%d%-%d%d$") then
    return date_str
  end
  local y, m, d = date_str:match("^(%d%d%d%d)(%d%d)(%d%d)$")
  if y and m and d then
    return string.format("%s-%s-%s", y, m, d)
  end
  local ym_y, ym_m = date_str:match("^(%d%d%d%d)(%d%d)$")
  if ym_y and ym_m then
    return string.format("%s-%s", ym_y, ym_m)
  end
  return date_str
end

-- 按具体日期查询适用的最近一期 LPR（满足 公布日期 <= 查询日期 中日期最近的一条）
function M.get_lpr_by_date(query_date)
  local data = M.load_data()
  if not data or not data.records then return nil end

  local norm_date = M.normalize_date(query_date)
  if not norm_date or #norm_date < 10 then return nil end

  for _, rec in ipairs(data.records) do
    if rec.date <= norm_date then
      return rec, norm_date
    end
  end

  -- 查询日期早于首期 (2019-08-20)，返回历史首期记录
  return data.records[#data.records], norm_date
end

-- 按年份查询该年发生公布的记录（降序排列）
function M.get_records_by_year(year_str)
  local data = M.load_data()
  if not data or not data.records then return {} end

  local y = tostring(year_str):match("^(%d%d%d%d)$")
  if not y then return {} end

  local list = {}
  for _, rec in ipairs(data.records) do
    if rec.date:sub(1, 4) == y then
      table.insert(list, rec)
    end
  end
  return list
end

-- 按年月查询公布记录
function M.get_records_by_year_month(ym_str)
  local data = M.load_data()
  if not data or not data.records then return {} end

  local norm = M.normalize_date(ym_str)
  if not norm then return {} end
  local target_ym = norm:sub(1, 7)

  local list = {}
  for _, rec in ipairs(data.records) do
    if rec.date:sub(1, 7) == target_ym then
      table.insert(list, rec)
    end
  end
  return list
end

-- 计算 LPR 倍数利率，保留两位小数
function M.get_lpr_multiple(record, multiple)
  if not record or not record.lpr1y then return "0.00%" end
  local mult = tonumber(multiple) or 1
  local val = record.lpr1y * mult
  return string.format("%.2f%%", val)
end

-- 预留未来民间借贷利息计算接口：根据起止日期自动拆分 LPR 变动周期
function M.get_lpr_periods(start_date, end_date)
  local norm_start = M.normalize_date(start_date)
  local norm_end = M.normalize_date(end_date)
  if not norm_start or not norm_end or norm_start > norm_end then
    return nil, "invalid date range"
  end

  local data = M.load_data()
  if not data or not data.records then return nil end

  -- 获取按升序排列的调整点
  local asc_records = {}
  for i = #data.records, 1, -1 do
    table.insert(asc_records, data.records[i])
  end

  local periods = {}
  local cur_start = norm_start

  for i, rec in ipairs(asc_records) do
    local next_rec = asc_records[i + 1]
    local next_date = next_rec and next_rec.date or "9999-12-31"

    if next_date > cur_start and rec.date <= norm_end then
      local p_end = (next_date <= norm_end) and next_date or norm_end
      table.insert(periods, {
        start_date = cur_start,
        end_date = p_end,
        lpr_date = rec.date,
        lpr1y = rec.lpr1y,
        lpr5y = rec.lpr5y,
        lpr1y_x4 = rec.lpr1y * 4,
      })
      cur_start = p_end
      if cur_start >= norm_end then break end
    end
  end

  return periods
end

-- 安全保存数据至 lpr.json 与 backup
function M.save_data(new_data)
  local is_valid, err = M.validate_data(new_data)
  if not is_valid then
    return false, "validation failed: " .. tostring(err)
  end

  -- 确保排序
  table.sort(new_data.records, function(a, b)
    return a.date > b.date
  end)

  local content = json.encode(new_data, true)
  local tmp_path = M.get_file_path("lpr.tmp")
  local target_path = M.get_file_path("lpr.json")
  local backup_path = M.get_file_path("lpr.backup.json")

  -- 1. 写临时文件
  local f, f_err = io.open(tmp_path, "w")
  if not f then return false, "cannot open tmp file: " .. tostring(f_err) end
  f:write(content)
  f:flush()
  f:close()

  -- 2. 重命名替换目标文件
  os.remove(target_path)
  local ren_ok = os.rename(tmp_path, target_path)
  if not ren_ok then
    -- 尝试以写模式覆盖
    local wf = io.open(target_path, "w")
    if wf then
      wf:write(content)
      wf:close()
      os.remove(tmp_path)
    else
      return false, "failed to replace lpr.json"
    end
  end

  -- 3. 同步写入 backup
  local bf = io.open(backup_path, "w")
  if bf then
    bf:write(content)
    bf:close()
  end

  cached_data = new_data
  last_loaded_time = os.time()
  return true
end

return M
