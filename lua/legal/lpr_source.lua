--[[
  lpr_source.lua
  数据源与网络响应解析：与业务逻辑完全解耦
--]]

local json = require("lpr_json")

local Source = {}

-- 中国货币网 (CFETS) 官方实时数据端点
Source.PRIMARY_URL = "https://www.chinamoney.com.cn/r/cms/www/chinamoney/data/currency/bk-lpr.json"

-- 解析官方 CWAP JSON 响应数据
function Source.parse_response(response_text)
  if type(response_text) ~= "string" or #response_text == 0 then
    return nil, "empty response"
  end

  local data, err = json.decode(response_text)
  if not data or type(data) ~= "table" then
    return nil, "invalid json: " .. tostring(err)
  end

  -- 检查业务返回码
  if data.head and data.head.rep_code and tostring(data.head.rep_code) ~= "200" then
    return nil, "rep_code is not 200: " .. tostring(data.head.rep_code)
  end

  local show_date = data.data and data.data.showDateCN
  if type(show_date) ~= "string" then
    return nil, "missing showDateCN"
  end

  local date_part = show_date:match("^(%d%d%d%d%-%d%d%-%d%d)")
  if not date_part then
    return nil, "cannot extract YYYY-MM-DD from " .. tostring(show_date)
  end

  local records = data.records
  if type(records) ~= "table" then
    return nil, "missing records array"
  end

  local lpr1y, lpr5y = nil, nil
  for _, item in ipairs(records) do
    if item.termCode == "1Y" then
      lpr1y = tonumber(item.shibor)
    elseif item.termCode == "5Y" then
      lpr5y = tonumber(item.shibor)
    end
  end

  if not lpr1y or lpr1y <= 0 or lpr1y > 30 then
    return nil, "invalid 1Y rate: " .. tostring(lpr1y)
  end
  if not lpr5y or lpr5y <= 0 or lpr5y > 30 then
    return nil, "invalid 5Y rate: " .. tostring(lpr5y)
  end

  return {
    date = date_part,
    lpr1y = lpr1y,
    lpr5y = lpr5y,
  }
end

return Source
