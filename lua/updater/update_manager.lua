-- 通用后台更新管理器；任务由 legal_data/update_jobs.json 声明。
local json = require("lpr_json")
local M, runtime = {}, {}
local DEFAULT_INTERVAL, DEFAULT_MAX, DEFAULT_TIMEOUT = 8 * 60 * 60, 3, 8

local function base_dir()
  if _G.rime_api and _G.rime_api.get_user_data_dir then return _G.rime_api.get_user_data_dir() end
  for _, p in ipairs({ "data/update/update_jobs.json", "Rime/data/update/update_jobs.json", "legal_data/update_jobs.json", "Rime/legal_data/update_jobs.json" }) do
    local f = io.open(p, "r")
    if f then f:close(); return p:match("^Rime") and "Rime" or "." end
  end
  return "."
end

local function data_path(name)
  local b = base_dir()
  local sep = package.config:sub(1, 1) or "/"
  for _, sub in ipairs({ "data" .. sep .. "update", "data" .. sep .. "legal", "legal_data" }) do
    local candidate = b .. sep .. sub .. sep .. name
    local f = io.open(candidate, "r")
    if f then
      f:close()
      return candidate
    end
  end
  return b .. sep .. "data" .. sep .. "update" .. sep .. name
end

local function read_json(path)
  local f = io.open(path, "r"); if not f then return nil end
  local content = f:read("*a"); f:close()
  local ok, value = pcall(json.decode, content or "")
  return (ok and type(value) == "table") and value or nil
end

local function atomic_write(path, value)
  local ok, content = pcall(json.encode, value, true); if not ok then return false end
  local tmp = path .. ".tmp"
  local f = io.open(tmp, "w"); if not f then return false end
  f:write(content); f:flush(); f:close()
  if os.rename(tmp, path) then return true end
  os.remove(path)
  if os.rename(tmp, path) then return true end
  os.remove(tmp); return false
end

local function config()
  local value = read_json(data_path("update_jobs.json"))
  return (value and type(value.jobs) == "table") and value or { poll_interval_seconds = DEFAULT_INTERVAL, jobs = {} }
end

local function state()
  local value = read_json(data_path("update_state.json")) or {}
  value.jobs = type(value.jobs) == "table" and value.jobs or {}
  return value
end

local function log(id, message)
  local f = io.open(data_path("update_manager.log"), "a"); if not f then return end
  f:write(string.format("[%s] [%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), id, message)); f:close()
end

local function job(id)
  local item = config().jobs[id]
  if type(item) ~= "table" then return nil end
  item.id = id
  return item
end

local function handler(item)
  local name = item and item.handler
  if type(name) ~= "string" or not name:match("^[%w_]+$") then return nil, "invalid handler" end
  local ok, value = pcall(require, "update_handlers." .. name)
  return (ok and type(value) == "table") and value or nil, ok and nil or tostring(value)
end

local function attempts(id, target)
  local item = state().jobs[id] or {}
  if item.attempt_date ~= os.date("%Y-%m-%d") or tostring(item.target or "") ~= tostring(target or "") then return 0 end
  return tonumber(item.attempt_count) or 0
end

local function retry_interval_elapsed(id, target, item)
  local saved = state().jobs[id] or {}
  if saved.attempt_date ~= os.date("%Y-%m-%d") or tostring(saved.target or "") ~= tostring(target or "") then
    return true
  end
  local interval = math.max(0, math.floor(tonumber(item.retry_interval_seconds) or DEFAULT_INTERVAL))
  local last = tonumber(saved.last_attempt_at) or 0
  return os.time() - last >= interval
end

local function record_attempt(id, target)
  local value, today = state(), os.date("%Y-%m-%d")
  local item = value.jobs[id] or {}
  if item.attempt_date ~= today or tostring(item.target or "") ~= tostring(target or "") then
    item.attempt_date, item.attempt_count = today, 0
  end
  item.target = target
  item.attempt_count = (tonumber(item.attempt_count) or 0) + 1
  item.last_attempt_at = os.time()
  value.jobs[id] = item; atomic_write(data_path("update_state.json"), value)
  return item.attempt_count
end

local function valid_url(url)
  return type(url) == "string" and url:match("^https://[%w%._~:/%?&=%%%@%-]+$") ~= nil
end

local VBS_CONTENT = [[
' silent_download.vbs <url> <path> <timeout>
' Windows 完全静默后台下载脚本：零窗口、零黑框
On Error Resume Next
Dim args, url, path, timeout, sh, ret, curl_cmd, http, stream, ps_cmd, fso
Set args = WScript.Arguments
If args.Count < 2 Then WScript.Quit 1
url = args(0)
path = args(1)
timeout = 8
If args.Count >= 3 Then timeout = CInt(args(2))

Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
ret = -1

' Tier 1: curl.exe (hidden with 0, wait with True)
curl_cmd = "curl.exe -s --max-time " & timeout & " -A ""Mozilla/5.0"" """ & url & """ -o """ & path & """"
ret = sh.Run(curl_cmd, 0, True)

If ret = 0 Then
    If Not fso.FileExists(path) Then
        ret = -1
    ElseIf fso.GetFile(path).Size = 0 Then
        fso.DeleteFile path, True
        ret = -1
    End If
End If

' Tier 2: MSXML2.ServerXMLHTTP.6.0 (in-process COM)
If ret <> 0 Then
    Err.Clear
    Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    If Err.Number = 0 And Not http Is Nothing Then
        http.open "GET", url, False
        http.setTimeouts 3000, 3000, timeout * 1000, timeout * 1000
        http.setRequestHeader "User-Agent", "Mozilla/5.0"
        http.send
        If Err.Number = 0 And http.status = 200 Then
            Set stream = CreateObject("ADODB.Stream")
            stream.Open
            stream.Type = 1
            stream.Write http.responseBody
            stream.SaveToFile path, 2
            stream.Close
            If fso.FileExists(path) And fso.GetFile(path).Size > 0 Then
                ret = 0
            End If
        End If
    End If
End If

' Tier 3: PowerShell fallback (hidden with 0, wait with True)
If ret <> 0 Then
    Err.Clear
    ps_cmd = "powershell -NoProfile -NonInteractive -Command ""$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing -TimeoutSec " & timeout & " -Uri '" & Replace(url, "'", "''") & "' -OutFile '" & Replace(path, "'", "''") & "'"""
    sh.Run ps_cmd, 0, True
End If
]]

local function ensure_silent_vbs(vbs_path)
  local f = io.open(vbs_path, "r")
  if f then
    f:close()
    return
  end
  local wf = io.open(vbs_path, "w")
  if wf then
    wf:write(VBS_CONTENT)
    wf:flush()
    wf:close()
  end
end

local function download(item, request)
  if type(request) ~= "table" or not valid_url(request.url) or type(request.tmp_path) ~= "string" then
    return false, "invalid download request"
  end
  local timeout = math.max(1, math.min(30, math.floor(tonumber(item.timeout_seconds) or DEFAULT_TIMEOUT)))
  if (package.config:sub(1, 1) or "/") == "\\" then
    local vbs_path = data_path("silent_download.vbs")
    ensure_silent_vbs(vbs_path)
    local cmd = string.format('start "" wscript.exe //B //Nologo "%s" "%s" "%s" %d', vbs_path, request.url, request.tmp_path, timeout)
    local called, result = pcall(os.execute, cmd)
    return called and result ~= nil and result ~= false, "failed to start wscript"
  end
  local cmd = string.format('curl -s --max-time %d -A "Mozilla/5.0" "%s" -o "%s" >/dev/null 2>&1 &', timeout, request.url, request.tmp_path)
  local called, result = pcall(os.execute, cmd)
  return called and result ~= nil and result ~= false, "failed to start curl"
end

function M.get_poll_interval()
  return math.max(60, math.floor(tonumber(config().poll_interval_seconds) or DEFAULT_INTERVAL))
end

function M.check_and_apply(id)
  local item = job(id); if not item or item.enabled == false then return false, false end
  local h, err = handler(item); if not h or type(h.check_and_apply) ~= "function" then return false, err end
  local ok, applied, consumed = pcall(h.check_and_apply, item)
  if consumed and runtime[id] then runtime[id].updating = false end
  if not ok then log(id, "APPLY_ERROR: " .. tostring(applied)); return false, tostring(applied) end
  return applied, consumed
end

function M.should_check(id)
  local item = job(id); if not item or item.enabled == false then return false end
  local h = handler(item); if not h or type(h.should_check) ~= "function" then return false end
  local ok, needed, target = pcall(h.should_check, item)
  if not ok or not needed then return false, target end
  local maximum = math.max(1, math.floor(tonumber(item.max_daily_attempts) or DEFAULT_MAX))
  return attempts(id, target) < maximum and retry_interval_elapsed(id, target, item), target
end

function M.trigger(id, force)
  local item = job(id); if not item or item.enabled == false then return false, "job disabled or missing" end
  local h, err = handler(item); if not h then return false, err end
  M.check_and_apply(id)
  local rt = runtime[id] or { updating = false, last_trigger = 0 }; runtime[id] = rt
  local now = os.time()
  if rt.updating and now - rt.last_trigger < 30 then return false, "already updating" end
  local ok, needed, target = pcall(h.should_check, item); if not ok then return false, tostring(needed) end
  if force and not target and type(h.force_target) == "function" then target = h.force_target(item) end
  if not force and not needed then return false, "no check needed" end
  local maximum = math.max(1, math.floor(tonumber(item.max_daily_attempts) or DEFAULT_MAX))
  if attempts(id, target) >= maximum then return false, "daily attempt limit reached" end
  if not retry_interval_elapsed(id, target, item) then return false, "retry interval not reached" end
  local request_ok, request = pcall(h.build_request, item, target); if not request_ok then return false, tostring(request) end
  -- 先持久化占用本次额度，再启动下载，避免同一进程内多个 Rime 引擎同时放行。
  local count = record_attempt(id, target)
  local started, start_err = download(item, request)
  if not started then log(id, "TRIGGER_FAILED: " .. tostring(start_err)); return false, start_err end
  rt.updating, rt.last_trigger = true, now
  log(id, string.format("TRIGGER: %s attempt %d/%d target=%s", force and "manual" or "auto", count, maximum, tostring(target or "")))
  return true
end

function M.run_all(force)
  local results = {}
  for id, item in pairs(config().jobs) do
    if type(item) == "table" and item.enabled ~= false then results[id] = { M.trigger(id, force) } end
  end
  return results
end

return M
