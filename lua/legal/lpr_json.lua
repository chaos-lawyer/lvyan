--[[
  lpr_json.lua
  A lightweight, zero-dependency JSON encoder/decoder in pure Lua.
  Compatible with Lua 5.1, 5.2, 5.3, 5.4, and LuaJIT.
--]]

local json = {}

-- Decoding
local function parse_value(str, i)
  local len = #str
  while i <= len do
    local c = str:sub(i, i)
    if c == " " or c == "\t" or c == "\n" or c == "\r" then
      i = i + 1
    elseif c == "{" then
      -- Object
      local obj = {}
      i = i + 1
      while i <= len do
        while i <= len and str:sub(i, i):match("%s") do i = i + 1 end
        if str:sub(i, i) == "}" then
          return obj, i + 1
        end
        -- parse key
        local key
        key, i = parse_value(str, i)
        if type(key) ~= "string" then
          error("Expected string key in object at position " .. i)
        end
        -- skip whitespace and colon
        while i <= len and str:sub(i, i):match("%s") do i = i + 1 end
        if str:sub(i, i) ~= ":" then
          error("Expected ':' at position " .. i)
        end
        i = i + 1
        -- parse value
        local val
        val, i = parse_value(str, i)
        obj[key] = val
        -- skip whitespace
        while i <= len and str:sub(i, i):match("%s") do i = i + 1 end
        local next_c = str:sub(i, i)
        if next_c == "," then
          i = i + 1
        elseif next_c == "}" then
          return obj, i + 1
        else
          error("Expected ',' or '}' at position " .. i)
        end
      end
      error("Unterminated object at position " .. i)
    elseif c == "[" then
      -- Array
      local arr = {}
      i = i + 1
      while i <= len do
        while i <= len and str:sub(i, i):match("%s") do i = i + 1 end
        if str:sub(i, i) == "]" then
          return arr, i + 1
        end
        local val
        val, i = parse_value(str, i)
        table.insert(arr, val)
        while i <= len and str:sub(i, i):match("%s") do i = i + 1 end
        local next_c = str:sub(i, i)
        if next_c == "," then
          i = i + 1
        elseif next_c == "]" then
          return arr, i + 1
        else
          error("Expected ',' or ']' at position " .. i)
        end
      end
      error("Unterminated array at position " .. i)
    elseif c == '"' then
      -- String
      local res = {}
      i = i + 1
      while i <= len do
        local sc = str:sub(i, i)
        if sc == '"' then
          return table.concat(res), i + 1
        elseif sc == "\\" then
          i = i + 1
          local esc = str:sub(i, i)
          if esc == '"' or esc == "\\" or esc == "/" then
            table.insert(res, esc)
          elseif esc == "b" then
            table.insert(res, "\b")
          elseif esc == "f" then
            table.insert(res, "\f")
          elseif esc == "n" then
            table.insert(res, "\n")
          elseif esc == "r" then
            table.insert(res, "\r")
          elseif esc == "t" then
            table.insert(res, "\t")
          elseif esc == "u" then
            local hex = str:sub(i + 1, i + 4)
            local code = tonumber(hex, 16)
            if code then
              if code < 0x80 then
                table.insert(res, string.char(code))
              elseif code < 0x800 then
                table.insert(res, string.char(0xC0 + math.floor(code / 64), 0x80 + (code % 64)))
              else
                table.insert(res, string.char(0xE0 + math.floor(code / 4096), 0x80 + (math.floor(code / 64) % 64), 0x80 + (code % 64)))
              end
              i = i + 4
            else
              table.insert(res, "\\u" .. hex)
            end
          else
            table.insert(res, esc)
          end
          i = i + 1
        else
          table.insert(res, sc)
          i = i + 1
        end
      end
      error("Unterminated string at position " .. i)
    elseif str:sub(i, i + 3) == "true" then
      return true, i + 4
    elseif str:sub(i, i + 4) == "false" then
      return false, i + 5
    elseif str:sub(i, i + 3) == "null" then
      return nil, i + 4
    else
      -- Number
      local num_str = str:match("^[%-%d%.eE%+]+", i)
      if num_str then
        local num = tonumber(num_str)
        if num ~= nil then
          return num, i + #num_str
        end
      end
      error("Unexpected token at position " .. i .. ": " .. str:sub(i, i + 10))
    end
  end
  return nil, i
end

function json.decode(str)
  if type(str) ~= "string" or #str == 0 then
    return nil, "empty string"
  end
  local ok, res = pcall(function()
    local val, _ = parse_value(str, 1)
    return val
  end)
  if ok then
    return res
  else
    return nil, res
  end
end

-- Encoding
local function escape_str(s)
  local subs = {
    ['"'] = '\\"',
    ["\\"] = "\\\\",
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
  }
  return '"' .. s:gsub('["\\%b%f%n%r%t]', subs) .. '"'
end

local function is_array(t)
  if type(t) ~= "table" then return false end
  local i = 1
  for _ in pairs(t) do
    if t[i] == nil then return false end
    i = i + 1
  end
  return true
end

function json.encode(val, indent, level)
  indent = indent or false
  level = level or 0
  local ind_str = indent and string.rep("  ", level) or ""
  local ind_next = indent and string.rep("  ", level + 1) or ""
  local newline = indent and "\n" or ""
  local space = indent and " " or ""

  local vtype = type(val)
  if vtype == "nil" then
    return "null"
  elseif vtype == "boolean" then
    return val and "true" or "false"
  elseif vtype == "number" then
    if val == math.floor(val) and val >= -2147483648 and val <= 2147483647 then
      return string.format("%d", val)
    else
      return string.format("%.2f", val):gsub("%.?0+$", function(s)
        return s:find("%.") and "" or s
      end)
    end
  elseif vtype == "string" then
    return escape_str(val)
  elseif vtype == "table" then
    if is_array(val) then
      local parts = {}
      for idx, item in ipairs(val) do
        table.insert(parts, ind_next .. json.encode(item, indent, level + 1))
      end
      if #parts == 0 then return "[]" end
      return "[" .. newline .. table.concat(parts, "," .. newline) .. newline .. ind_str .. "]"
    else
      local parts = {}
      local keys = {}
      for k in pairs(val) do
        table.insert(keys, tostring(k))
      end
      table.sort(keys)
      for _, k in ipairs(keys) do
        local v = val[k]
        local item_str = ind_next .. escape_str(k) .. ":" .. space .. json.encode(v, indent, level + 1)
        table.insert(parts, item_str)
      end
      if #parts == 0 then return "{}" end
      return "{" .. newline .. table.concat(parts, "," .. newline) .. newline .. ind_str .. "}"
    end
  else
    return '"' .. tostring(val) .. '"'
  end
end

return json
