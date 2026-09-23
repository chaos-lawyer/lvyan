--[[
  name_utils.lua
  人名模式辅助工具模块：
  1. 独立用户人名词典 (name_user_dict.txt) 的读取、更新与持久化
  2. 基础姓氏与名字集合的快速检索
  3. 小鹤直接辅助码匹配
--]]

local M = {}

M.user_dict = {}
M.user_dict_loaded = false
M.surnames = nil
M.compound_surnames = nil
M.given_names_2 = nil
M.aux_codes = nil

--------------------------------------------------------------------------------
-- 1. 获取用户数据目录与词典文件路径
--------------------------------------------------------------------------------
function M.get_user_dict_path()
  local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
  if user_dir ~= "" then
    return user_dir .. "/name_user_dict.txt"
  end
  return "name_user_dict.txt"
end

--------------------------------------------------------------------------------
-- 2. 读取独立用户人名词典
--------------------------------------------------------------------------------
function M.load_user_dict()
  if M.user_dict_loaded then
    return M.user_dict
  end

  local path = M.get_user_dict_path()
  local f = io.open(path, "r")
  M.user_dict = {}
  if f then
    for line in f:lines() do
      local clean = line:match("[^\r\n]+")
      if clean and not clean:match("^#") then
        local code, text, count_str, time_str = clean:match("([^\t]+)\t([^\t]+)\t?(%d*)\t?(%d*)")
        if code and text then
          local count = tonumber(count_str) or 1
          local t = tonumber(time_str) or os.time()
          if not M.user_dict[code] then
            M.user_dict[code] = {}
          end
          table.insert(M.user_dict[code], {
            text = text,
            count = count,
            last_time = t,
          })
        end
      end
    end
    f:close()
  end
  M.user_dict_loaded = true
  return M.user_dict
end

--------------------------------------------------------------------------------
-- 3. 保存独立用户人名词典
--------------------------------------------------------------------------------
function M.save_user_dict()
  local path = M.get_user_dict_path()
  local f = io.open(path, "w")
  if not f then return end

  f:write("# Rime name_user_dict\n# code\ttext\tcount\tlast_time\n")
  for code, entries in pairs(M.user_dict) do
    for _, e in ipairs(entries) do
      f:write(string.format("%s\t%s\t%d\t%d\n", code, e.text, e.count, e.last_time))
    end
  end
  f:close()
end

--------------------------------------------------------------------------------
-- 4. 记录用户人名上屏学习
--------------------------------------------------------------------------------
function M.record_commit(code, text)
  if not code or not text or code == "" or text == "" then return end
  M.load_user_dict()

  if not M.user_dict[code] then
    M.user_dict[code] = {}
  end

  local found = false
  for _, e in ipairs(M.user_dict[code]) do
    if e.text == text then
      e.count = e.count + 1
      e.last_time = os.time()
      found = true
      break
    end
  end

  if not found then
    table.insert(M.user_dict[code], {
      text = text,
      count = 1,
      last_time = os.time(),
    })
  end

  -- 按频次与最近时间排序
  table.sort(M.user_dict[code], function(a, b)
    if a.count == b.count then
      return a.last_time > b.last_time
    end
    return a.count > b.count
  end)

  M.save_user_dict()
end

--------------------------------------------------------------------------------
-- 5. 加载姓氏与双字名集合
--------------------------------------------------------------------------------
function M.load_name_sets()
  if M.surnames then return end

  local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
  local prefix = user_dir ~= "" and (user_dir .. "/") or ""

  -- 1. 单姓表
  M.surnames = {}
  local s_file = io.open(prefix .. "dicts/name/surname.dict.yaml", "r")
    or io.open("dicts/name/surname.dict.yaml", "r")
    or io.open(prefix .. "name_data/surname.dict.yaml", "r")
    or io.open("name_data/surname.dict.yaml", "r")
    or io.open(prefix .. "name_builder/data/surname.txt", "r")
    or io.open("name_builder/data/surname.txt", "r")
  if s_file then
    local in_dict = false
    for line in s_file:lines() do
      local clean = line:match("[^\r\n]+")
      if clean then
        if clean == "..." then
          in_dict = true
        elseif not in_dict and not clean:match("^#") then
          M.surnames[clean] = true
        elseif in_dict and not clean:match("^#") then
          local s = clean:match("^([^\t]+)")
          if s then M.surnames[s] = true end
        end
      end
    end
    s_file:close()
  end

  -- 2. 复姓表
  M.compound_surnames = {}
  local cs_file = io.open(prefix .. "dicts/name/compound_surname.dict.yaml", "r")
    or io.open("dicts/name/compound_surname.dict.yaml", "r")
    or io.open(prefix .. "name_data/compound_surname.dict.yaml", "r")
    or io.open("name_data/compound_surname.dict.yaml", "r")
    or io.open(prefix .. "name_builder/data/compound_surname.txt", "r")
    or io.open("name_builder/data/compound_surname.txt", "r")
  if cs_file then
    local in_dict = false
    for line in cs_file:lines() do
      local clean = line:match("[^\r\n]+")
      if clean then
        if clean == "..." then
          in_dict = true
        elseif not in_dict and not clean:match("^#") then
          M.compound_surnames[clean] = true
        elseif in_dict and not clean:match("^#") then
          local cs = clean:match("^([^\t]+)")
          if cs then M.compound_surnames[cs] = true end
        end
      end
    end
    cs_file:close()
  end

  -- 3. 双字名表
  M.given_names_2 = {}
  local g2_file = io.open(prefix .. "dicts/name/given_name_2.dict.yaml", "r")
    or io.open("dicts/name/given_name_2.dict.yaml", "r")
    or io.open(prefix .. "name_data/given_name_2.dict.yaml", "r")
    or io.open("name_data/given_name_2.dict.yaml", "r")
  if g2_file then
    local in_dict = false
    for line in g2_file:lines() do
      local clean = line:match("[^\r\n]+")
      if clean then
        if clean == "..." then
          in_dict = true
        elseif in_dict and not clean:match("^#") then
          local g2 = clean:match("^([^\t]+)")
          if g2 then M.given_names_2[g2] = true end
        end
      end
    end
    g2_file:close()
  end
end

function M.is_surname(s)
  M.load_name_sets()
  return M.surnames and M.surnames[s] or false
end

function M.is_compound_surname(cs)
  M.load_name_sets()
  return M.compound_surnames and M.compound_surnames[cs] or false
end

function M.is_given_name_2(g2)
  M.load_name_sets()
  return M.given_names_2 and M.given_names_2[g2] or false
end

--------------------------------------------------------------------------------
-- 6. 小鹤辅助码匹配
--------------------------------------------------------------------------------
function M.load_aux_codes()
  if M.aux_codes then return M.aux_codes end
  M.aux_codes = {}
  local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
  local prefix = user_dir ~= "" and (user_dir .. "/") or ""
  local file = io.open(prefix .. "lua/aux_code/flypy_full.txt", "r") or io.open("lua/aux_code/flypy_full.txt", "r")
  if file then
    for line in file:lines() do
      local clean = line:match("[^\r\n]+")
      if clean then
        local k, v = clean:match("([^=]+)=(.+)")
        if k and v then
          M.aux_codes[k] = v
        end
      end
    end
    file:close()
  end
  return M.aux_codes
end

function M.match_aux(text, aux_str)
  if not aux_str or aux_str == "" then return true end
  if not text or text == "" then return false end
  M.load_aux_codes()

  -- 获取姓名首字
  local first_char = nil
  for _, cp in utf8.codes(text) do
    first_char = utf8.char(cp)
    break
  end
  if not first_char then return false end

  local code = M.aux_codes[first_char]
  if not code then return true end -- 辅码表中无记录时默认放行

  for val in code:gmatch("%S+") do
    if val:sub(1, #aux_str) == aux_str then
      return true
    end
  end
  return false
end

return M
