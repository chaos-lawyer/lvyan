--[[
  contacts_loader.lua
  Google Contacts CSV 加载、解析、规范化与索引构建引擎：
  1. 动态表头识别（支持不限列数、任意顺序与多语言 Google 导出字段）
  2. 电话号码智能拆分（支持单元格内含 ::: 或换行符的多值结构）
  3. 联系方式选择优先级（Mobile > Main > Work > Home > 第一个号码 > Email）
  4. 电话号码轻度规范化（保留 + 与数字，删除无意义空格与分隔符）
  5. 隐私脱敏注释展示（如 138****5678）
  6. 内存缓存与热加载探测（按文件大小与路径动态检测）
--]]

local csv = require("contacts_csv")
local pinyin = require("contacts_pinyin")

local M = {}

-- 缓存数据
M.cached_entries = nil
M.cached_file_path = nil
M.cached_file_size = -1
M.load_error = nil

local function get_candidate_paths()
  local user_dir = _G.rime_api and _G.rime_api.get_user_data_dir and _G.rime_api.get_user_data_dir() or ""
  local paths = {}
  if user_dir ~= "" then
    table.insert(paths, user_dir .. "/dicts/flypy/contacts.csv")
    table.insert(paths, user_dir .. "/contacts.csv")
  end
  table.insert(paths, "dicts/flypy/contacts.csv")
  table.insert(paths, "contacts.csv")
  table.insert(paths, "Rime/dicts/flypy/contacts.csv")
  table.insert(paths, "Rime/contacts.csv")
  return paths
end

function M.find_contacts_file()
  local paths = get_candidate_paths()
  for _, p in ipairs(paths) do
    local f = io.open(p, "rb")
    if f then
      f:close()
      return p
    end
  end
  return nil
end

local function get_file_size(filepath)
  local f = io.open(filepath, "rb")
  if not f then return -1 end
  local size = f:seek("end") or -1
  f:close()
  return size
end

function M.should_reload()
  local current_path = M.find_contacts_file()
  if not current_path then
    if M.cached_file_path ~= nil then
      return true
    end
    return false
  end

  if current_path ~= M.cached_file_path then
    return true
  end

  local current_size = get_file_size(current_path)
  if current_size ~= M.cached_file_size then
    return true
  end

  return false
end

-- 电话号码规范化
function M.normalize_phone(raw)
  if not raw or raw == "" then return "" end
  local has_plus = (raw:match("^%s*%+") ~= nil)
  local digits = raw:gsub("%D", "")
  if digits == "" then return "" end
  return (has_plus and "+" or "") .. digits
end

-- 隐私脱敏注释
function M.mask_phone(phone)
  if not phone or phone == "" then return "" end
  local digits = phone:gsub("%D", "")
  local has_plus = phone:sub(1, 1) == "+"

  -- 处理包含中国区号 +86 或 86 的 13 位手机号
  if #digits == 13 and digits:sub(1, 2) == "86" then
    local p = (has_plus and "+86 " or "86 ")
    return p .. digits:sub(3, 5) .. "****" .. digits:sub(10, 13)
  end

  local prefix = has_plus and "+" or ""
  if #digits == 11 then
    return prefix .. digits:sub(1, 3) .. "****" .. digits:sub(8, 11)
  elseif #digits >= 7 then
    return prefix .. digits:sub(1, 3) .. "****" .. digits:sub(-4)
  elseif #digits >= 5 then
    return prefix .. digits:sub(1, 2) .. "***" .. digits:sub(-2)
  end
  return phone
end

function M.mask_email(email)
  if not email or email == "" then return "" end
  local name, domain = email:match("^([^@]+)@(.+)$")
  if not name or not domain then return email end
  if #name <= 2 then
    return name:sub(1, 1) .. "***@" .. domain
  end
  return name:sub(1, 2) .. "***@" .. domain
end

-- 电话类型优先级
local function phone_type_rank(label)
  local l = (label or ""):lower()
  if l:find("mobile") or l:find("手机") then return 1 end
  if l:find("main") or l:find("主要") then return 2 end
  if l:find("work") or l:find("工作") then return 3 end
  if l:find("home") or l:find("住宅") then return 4 end
  return 5
end

local function map_type_display(label, default_name)
  local l = (label or ""):lower()
  if l:find("mobile") or l:find("手机") then return "手机" end
  if l:find("main") or l:find("主要") then return "主要" end
  if l:find("work") or l:find("工作") then return "工作" end
  if l:find("home") or l:find("住宅") then return "住宅" end
  if label and label ~= "" and #label <= 12 and not label:find("mycontacts") and not label:find("http") then
    return label:gsub("^%s*(.-)%s*$", "%1")
  end
  return default_name or "电话"
end

-- 动态识别 Google 表头列索引
local function analyze_headers(headers)
  local mapping = {
    name = nil,
    first_name = nil,
    last_name = nil,
    middle_name = nil,
    nickname = nil,
    org_name = nil,
    phones = {}, -- list of { type_idx, val_idx, num }
    emails = {}, -- list of { type_idx, val_idx, num }
  }

  local phone_map = {}
  local email_map = {}

  for idx, h in ipairs(headers) do
    local clean = h:gsub("^%s*(.-)%s*$", "%1")
    local lower = clean:lower()

    if lower == "name" or clean == "姓名" or lower == "full name" then
      mapping.name = idx
    elseif lower == "first name" or lower == "given name" or clean == "名" then
      mapping.first_name = idx
    elseif lower == "last name" or lower == "family name" or clean == "姓" then
      mapping.last_name = idx
    elseif lower == "middle name" or clean == "中间名" then
      mapping.middle_name = idx
    elseif lower == "nickname" or clean == "昵称" then
      mapping.nickname = idx
    elseif lower == "organization name" or lower == "organization 1 - name" or lower == "company" or clean == "公司" then
      mapping.org_name = idx
    end

    -- 电话字段检测
    if lower:find("phone") or clean:find("电话") or clean:find("手机") then
      local num = lower:match("phone%s*(%d*)") or ""
      if num == "" then num = "1" end
      if not phone_map[num] then phone_map[num] = {} end
      if lower:find("value") or lower:find("值") or lower:find("号码") or (not lower:find("type") and not lower:find("label")) then
        phone_map[num].val_idx = idx
      elseif lower:find("type") or lower:find("label") or clean:find("类型") or clean:find("标签") then
        phone_map[num].type_idx = idx
      end
    end

    -- 邮箱字段检测
    if lower:find("e%-?mail") or clean:find("邮箱") or clean:find("电邮") then
      local num = lower:match("e%-?mail%s*(%d*)") or ""
      if num == "" then num = "1" end
      if not email_map[num] then email_map[num] = {} end
      if lower:find("value") or lower:find("值") or (not lower:find("type") and not lower:find("label")) then
        email_map[num].val_idx = idx
      elseif lower:find("type") or lower:find("label") or clean:find("类型") or clean:find("标签") then
        email_map[num].type_idx = idx
      end
    end
  end

  for num, item in pairs(phone_map) do
    if item.val_idx then
      table.insert(mapping.phones, {
        num = tonumber(num) or 99,
        val_idx = item.val_idx,
        type_idx = item.type_idx,
      })
    end
  end
  table.sort(mapping.phones, function(a, b) return a.num < b.num end)

  for num, item in pairs(email_map) do
    if item.val_idx then
      table.insert(mapping.emails, {
        num = tonumber(num) or 99,
        val_idx = item.val_idx,
        type_idx = item.type_idx,
      })
    end
  end
  table.sort(mapping.emails, function(a, b) return a.num < b.num end)

  return mapping
end

-- 判断字符串是否包含中文字符
local function has_chinese(str)
  for _, cp in utf8.codes(str) do
    if cp >= 0x4E00 and cp <= 0x9FFF or cp >= 0x3400 and cp <= 0x4DBF then
      return true
    end
  end
  return false
end

-- 解析单行联系人构建条目
local function extract_contact_items(row, col_map, global_id)
  local name = ""
  if col_map.name and row[col_map.name] and row[col_map.name] ~= "" then
    name = row[col_map.name]:gsub("^%s*(.-)%s*$", "%1")
  end

  local first = col_map.first_name and row[col_map.first_name] and row[col_map.first_name]:gsub("^%s*(.-)%s*$", "%1") or ""
  local last = col_map.last_name and row[col_map.last_name] and row[col_map.last_name]:gsub("^%s*(.-)%s*$", "%1") or ""
  local middle = col_map.middle_name and row[col_map.middle_name] and row[col_map.middle_name]:gsub("^%s*(.-)%s*$", "%1") or ""

  if name == "" then
    if last ~= "" and first ~= "" then
      if has_chinese(last) or has_chinese(first) then
        name = last .. (middle ~= "" and middle or "") .. first
      else
        name = first .. (middle ~= "" and (" " .. middle) or "") .. " " .. last
      end
    elseif first ~= "" then
      name = first
    elseif last ~= "" then
      name = last
    elseif col_map.nickname and row[col_map.nickname] and row[col_map.nickname] ~= "" then
      name = row[col_map.nickname]:gsub("^%s*(.-)%s*$", "%1")
    elseif col_map.org_name and row[col_map.org_name] and row[col_map.org_name] ~= "" then
      name = row[col_map.org_name]:gsub("^%s*(.-)%s*$", "%1")
    end
  end

  if name == "" then return {} end

  -- 收集并拆分所有电话号码
  local raw_phones = {}
  for _, p_col in ipairs(col_map.phones) do
    local raw_val = row[p_col.val_idx] or ""
    local raw_type = (p_col.type_idx and row[p_col.type_idx]) or ""

    if raw_val ~= "" then
      -- 单元格中含 ::: 或换行符时进行拆分
      local parts = {}
      if raw_val:find(":::") then
        for part in raw_val:gmatch("[^:]+") do
          local trimmed = part:gsub("^%s*(.-)%s*$", "%1")
          if trimmed ~= "" and trimmed ~= ":::" then
            table.insert(parts, trimmed)
          end
        end
      elseif raw_val:find("\n") then
        for part in raw_val:gmatch("[^\r\n]+") do
          local trimmed = part:gsub("^%s*(.-)%s*$", "%1")
          if trimmed ~= "" then table.insert(parts, trimmed) end
        end
      else
        table.insert(parts, raw_val)
      end

      for _, part in ipairs(parts) do
        local norm = M.normalize_phone(part)
        local digits = norm:gsub("%D", "")
        if #digits >= 3 then
          table.insert(raw_phones, {
            phone = norm,
            label = raw_type,
            rank = phone_type_rank(raw_type),
          })
        end
      end
    end
  end

  -- 按优先级排序电话号码
  table.sort(raw_phones, function(a, b) return a.rank < b.rank end)

  -- 去重电话号码保留最高优先级的 label
  local distinct_phones = {}
  local seen_phones = {}
  for _, item in ipairs(raw_phones) do
    if not seen_phones[item.phone] then
      seen_phones[item.phone] = true
      table.insert(distinct_phones, item)
    end
  end

  -- 收集 Emails
  local raw_emails = {}
  for _, e_col in ipairs(col_map.emails) do
    local raw_val = row[e_col.val_idx] or ""
    local raw_type = (e_col.type_idx and row[e_col.type_idx]) or ""
    if raw_val:find("@") then
      local trimmed = raw_val:gsub("^%s*(.-)%s*$", "%1")
      if trimmed ~= "" then
        table.insert(raw_emails, {
          email = trimmed,
          label = raw_type ~= "" and raw_type or "邮箱",
        })
      end
    end
  end

  local codes = pinyin.convert_name(name)
  local entries = {}

  if #distinct_phones > 0 then
    for i, p_item in ipairs(distinct_phones) do
      local type_name = map_type_display(p_item.label, "电话")
      local masked = M.mask_phone(p_item.phone)
      local comment = string.format("〔%s %s〕", type_name, masked)
      table.insert(entries, {
        id = global_id * 100 + i,
        name = name,
        commit_value = p_item.phone,
        type_name = type_name,
        comment = comment,
        is_phone = true,
        full_pinyin = codes.full_pinyin,
        initials = codes.initials,
        flypy = codes.flypy,
        flypy_initials = codes.flypy_initials,
      })
    end
  elseif #raw_emails > 0 then
    local e_item = raw_emails[1]
    local masked = M.mask_email(e_item.email)
    local comment = string.format("〔邮箱 %s〕", masked)
    table.insert(entries, {
      id = global_id * 100 + 1,
      name = name,
      commit_value = e_item.email,
      type_name = "邮箱",
      comment = comment,
      is_phone = false,
      full_pinyin = codes.full_pinyin,
      initials = codes.initials,
      flypy = codes.flypy,
      flypy_initials = codes.flypy_initials,
    })
  end

  return entries
end

function M.load_contacts(force)
  if not force and M.cached_entries and not M.should_reload() then
    return M.cached_entries, M.load_error
  end

  local filepath = M.find_contacts_file()
  if not filepath then
    M.cached_entries = {}
    M.cached_file_path = nil
    M.cached_file_size = -1
    M.load_error = "未找到 contacts.csv"
    return M.cached_entries, M.load_error
  end

  local rows, err = csv.parse_file(filepath)
  if not rows or #rows == 0 then
    M.cached_entries = {}
    M.cached_file_path = filepath
    M.cached_file_size = get_file_size(filepath)
    M.load_error = err or "contacts.csv 为空"
    return M.cached_entries, M.load_error
  end

  local col_map = analyze_headers(rows[1])
  local entries = {}
  local global_id = 0

  for i = 2, #rows do
    local row = rows[i]
    if #row > 0 then
      global_id = global_id + 1
      local items = extract_contact_items(row, col_map, global_id)
      for _, item in ipairs(items) do
        table.insert(entries, item)
      end
    end
  end

  M.cached_entries = entries
  M.cached_file_path = filepath
  M.cached_file_size = get_file_size(filepath)
  M.load_error = nil

  return M.cached_entries, nil
end

return M
