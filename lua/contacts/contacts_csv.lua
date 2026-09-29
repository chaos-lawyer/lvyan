--[[
  contacts_csv.lua
  RFC 4180 标准 CSV 解析器：
  - 支持 UTF-8 及 UTF-8 BOM 自动剥离
  - 支持英文逗号分隔符
  - 支持双引号包裹字段与 "" 转义
  - 支持字段内部包含逗号、双引号和换行符（CRLF / LF）
  - 支持空字段、变长列数与动态表头
--]]

local M = {}

function M.strip_bom(text)
  if not text then return "" end
  if text:sub(1, 3) == "\239\187\191" then
    return text:sub(4)
  end
  return text
end

function M.parse_string(content)
  content = M.strip_bom(content)
  local rows = {}
  local current_row = {}
  local field_parts = {}

  local len = #content
  local i = 1
  local state = "FIELD_START" -- "FIELD_START", "UNQUOTED", "QUOTED", "AFTER_QUOTE"

  while i <= len do
    local b = content:byte(i)
    if state == "FIELD_START" then
      if b == 34 then -- '"'
        state = "QUOTED"
        i = i + 1
      elseif b == 44 then -- ','
        table.insert(current_row, "")
        i = i + 1
      elseif b == 13 then -- '\r'
        if i + 1 <= len and content:byte(i + 1) == 10 then
          i = i + 1
        end
        table.insert(current_row, "")
        table.insert(rows, current_row)
        current_row = {}
        i = i + 1
      elseif b == 10 then -- '\n'
        table.insert(current_row, "")
        table.insert(rows, current_row)
        current_row = {}
        i = i + 1
      else
        table.insert(field_parts, string.char(b))
        state = "UNQUOTED"
        i = i + 1
      end
    elseif state == "UNQUOTED" then
      if b == 44 then -- ','
        table.insert(current_row, table.concat(field_parts))
        field_parts = {}
        state = "FIELD_START"
        i = i + 1
      elseif b == 13 then -- '\r'
        if i + 1 <= len and content:byte(i + 1) == 10 then
          i = i + 1
        end
        table.insert(current_row, table.concat(field_parts))
        field_parts = {}
        table.insert(rows, current_row)
        current_row = {}
        state = "FIELD_START"
        i = i + 1
      elseif b == 10 then -- '\n'
        table.insert(current_row, table.concat(field_parts))
        field_parts = {}
        table.insert(rows, current_row)
        current_row = {}
        state = "FIELD_START"
        i = i + 1
      else
        table.insert(field_parts, string.char(b))
        i = i + 1
      end
    elseif state == "QUOTED" then
      if b == 34 then -- '"'
        if i + 1 <= len and content:byte(i + 1) == 34 then
          table.insert(field_parts, '"')
          i = i + 2
        else
          state = "AFTER_QUOTE"
          i = i + 1
        end
      else
        table.insert(field_parts, string.char(b))
        i = i + 1
      end
    elseif state == "AFTER_QUOTE" then
      if b == 44 then -- ','
        table.insert(current_row, table.concat(field_parts))
        field_parts = {}
        state = "FIELD_START"
        i = i + 1
      elseif b == 13 then -- '\r'
        if i + 1 <= len and content:byte(i + 1) == 10 then
          i = i + 1
        end
        table.insert(current_row, table.concat(field_parts))
        field_parts = {}
        table.insert(rows, current_row)
        current_row = {}
        state = "FIELD_START"
        i = i + 1
      elseif b == 10 then -- '\n'
        table.insert(current_row, table.concat(field_parts))
        field_parts = {}
        table.insert(rows, current_row)
        current_row = {}
        state = "FIELD_START"
        i = i + 1
      else
        -- 闭合双引号后异常字符容错处理
        i = i + 1
      end
    end
  end

  if state == "UNQUOTED" or state == "AFTER_QUOTE" or #current_row > 0 or #field_parts > 0 then
    table.insert(current_row, table.concat(field_parts))
    table.insert(rows, current_row)
  end

  return rows
end

function M.parse_file(filepath)
  local f = io.open(filepath, "rb")
  if not f then
    return nil, "cannot open file: " .. tostring(filepath)
  end
  local content = f:read("*a")
  f:close()
  if not content or content == "" then
    return {}, nil
  end
  return M.parse_string(content), nil
end

return M
