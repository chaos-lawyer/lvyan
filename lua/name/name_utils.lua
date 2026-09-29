--[[
  name_utils.lua
  人名模式辅助工具模块（基于 120W 现代姓名语料强化版）：
  1. 独立用户人名词典 (name_user_dict_v2.txt) 的读取、更新、持久化与撤销
  2. 严格分层的姓氏与名字集合及权重索引
  3. 支持名字字位（首字、末字）及姓氏的直接辅助码消歧
--]]

local M = {}

M.user_dict = {}
M.user_dict_loaded = false
M.surnames = nil
M.compound_surnames = nil
M.given_names_2 = nil
M.given_names_1 = nil
M.given_first = nil
M.given_last = nil
M.aux_codes = nil

--------------------------------------------------------------------------------
-- 1. 获取用户数据目录与词典文件路径（隔离旧虚拟学习数据）
--------------------------------------------------------------------------------
function M.get_user_dict_path()
  local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
  if user_dir ~= "" then
    return user_dir .. "/name_user_dict_v2.txt"
  end
  return "name_user_dict_v2.txt"
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

  f:write("# Rime name_user_dict_v2\n# code\ttext\tcount\tlast_time\n")
  for code, entries in pairs(M.user_dict) do
    for _, e in ipairs(entries) do
      f:write(string.format("%s\t%s\t%d\t%d\n", code, e.text, e.count, e.last_time))
    end
  end
  f:close()
end

--------------------------------------------------------------------------------
-- 4. 记录用户人名上屏学习与撤销
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

  table.sort(M.user_dict[code], function(a, b)
    if a.count == b.count then
      return a.last_time > b.last_time
    end
    return a.count > b.count
  end)

  M.save_user_dict()
end

function M.revoke_commit(code, text)
  if not code or not text or not M.user_dict[code] then return end
  local filtered = {}
  for _, e in ipairs(M.user_dict[code]) do
    if e.text ~= text then
      table.insert(filtered, e)
    end
  end
  M.user_dict[code] = filtered
  M.save_user_dict()
end

--------------------------------------------------------------------------------
-- 5. 加载姓名各分层数据集合
--------------------------------------------------------------------------------
local function load_yaml_dict(prefix, filename)
  local map = {}
  local paths = {
    prefix .. "dicts/name/" .. filename,
    "dicts/name/" .. filename,
    prefix .. "name_data/" .. filename,
    "name_data/" .. filename,
  }
  local file = nil
  for _, p in ipairs(paths) do
    file = io.open(p, "r")
    if file then break end
  end
  if not file then return map end

  local in_dict = false
  for line in file:lines() do
    local clean = line:match("[^\r\n]+")
    if clean then
      if clean == "..." then
        in_dict = true
      elseif in_dict and not clean:match("^#") then
        local key, _, weight = clean:match("^([^\t]+)\t?([^\t]*)\t?(%d*)")
        if key then
          map[key] = tonumber(weight) or 1000
        end
      end
    end
  end
  file:close()
  return map
end

function M.load_name_sets()
  if M.surnames then return end

  local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
  local prefix = user_dir ~= "" and (user_dir .. "/") or ""

  M.surnames = load_yaml_dict(prefix, "surname.dict.yaml")
  M.compound_surnames = load_yaml_dict(prefix, "compound_surname.dict.yaml")
  M.given_names_2 = load_yaml_dict(prefix, "given_name_2.dict.yaml")
  M.given_names_1 = load_yaml_dict(prefix, "given_name_1.dict.yaml")
  M.given_first = load_yaml_dict(prefix, "given_name_first.dict.yaml")
  M.given_last = load_yaml_dict(prefix, "given_name_last.dict.yaml")
end

function M.is_surname(s)
  M.load_name_sets()
  return (M.surnames and M.surnames[s] ~= nil)
end

function M.get_surname_weight(s)
  M.load_name_sets()
  return M.surnames and M.surnames[s] or 0
end

function M.is_compound_surname(cs)
  M.load_name_sets()
  return (M.compound_surnames and M.compound_surnames[cs] ~= nil)
end

function M.get_compound_surname_weight(cs)
  M.load_name_sets()
  return M.compound_surnames and M.compound_surnames[cs] or 0
end

function M.is_given_name_2(g2)
  M.load_name_sets()
  return (M.given_names_2 and M.given_names_2[g2] ~= nil)
end

function M.get_given_name_2_weight(g2)
  M.load_name_sets()
  return M.given_names_2 and M.given_names_2[g2] or 0
end

function M.is_given_name_1(g1)
  M.load_name_sets()
  return (M.given_names_1 and M.given_names_1[g1] ~= nil)
end

function M.get_given_name_1_weight(g1)
  M.load_name_sets()
  return M.given_names_1 and M.given_names_1[g1] or 0
end

function M.get_first_char_weight(ch)
  M.load_name_sets()
  return M.given_first and M.given_first[ch] or 0
end

function M.get_last_char_weight(ch)
  M.load_name_sets()
  return M.given_last and M.given_last[ch] or 0
end

--------------------------------------------------------------------------------
-- 6. 小鹤辅助码匹配（支持名字字位及姓氏）
--------------------------------------------------------------------------------
function M.load_aux_codes()
  if M.aux_codes then return M.aux_codes end
  M.aux_codes = {}
  local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
  local prefix = user_dir ~= "" and (user_dir .. "/") or ""
  local shared_dir = rime_api and rime_api.get_shared_data_dir and rime_api.get_shared_data_dir() or ""
  local shared_prefix = shared_dir ~= "" and (shared_dir .. "/") or ""
  local paths = {
    prefix .. "lua/aux_code/flypy_full.txt",
    "lua/aux_code/flypy_full.txt",
    shared_prefix .. "lua/aux_code/flypy_full.txt",
    prefix .. "Rime/lua/aux_code/flypy_full.txt",
    "Rime/lua/aux_code/flypy_full.txt",
    "../lua/aux_code/flypy_full.txt",
  }
  local file = nil
  for _, p in ipairs(paths) do
    file = io.open(p, "r")
    if file then break end
  end

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

-- 检查某个汉字是否匹配给定的辅码前缀
function M.char_match_aux(ch, aux_str)
  if not aux_str or aux_str == "" then return true end
  if not ch or ch == "" then return false end
  M.load_aux_codes()
  local code = M.aux_codes[ch]
  if not code then return false end

  local target = aux_str:lower()
  for val in code:gmatch("%S+") do
    if val:sub(1, #target) == target then
      return true
    end
  end
  return false
end

-- 姓名整体辅码匹配：支持名字末字、首字或姓氏字位
-- 返回值：matched (boolean), matched_position ("last"|"middle"|"first"|"surname"|nil)
function M.match_aux(text, aux_str)
  if not aux_str or aux_str == "" then return true, nil end
  if not text or text == "" then return false, nil end

  local chars = {}
  for _, cp in utf8.codes(text) do
    table.insert(chars, utf8.char(cp))
  end
  local len = #chars
  if len == 0 then return false, nil end

  -- 优先检查名字末字（人名歧义消歧最常见位置）
  if len >= 2 and M.char_match_aux(chars[len], aux_str) then
    return true, "last"
  end

  -- 检查名字中间字 (如三字名次字、四字名第2/3字)
  if len >= 3 then
    for i = 2, len - 1 do
      if M.char_match_aux(chars[i], aux_str) then
        return true, "middle"
      end
    end
  end

  -- 检查姓氏（兼顾首字姓氏辅码）
  if M.char_match_aux(chars[1], aux_str) then
    return true, "surname"
  end

  return false, nil
end

return M
