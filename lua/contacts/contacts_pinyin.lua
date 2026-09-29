--[[
  contacts_pinyin.lua
  汉字拼音转换与小鹤双拼编解码模块：
  1. 严格对齐 double_pinyin_flypy.schema.yaml 的小鹤双拼映射规则
  2. 整合 surname.dict.yaml（姓氏多音字消歧，如曾/单/解/仇/朴/查）
  3. 整合 rime_mint.chars.dict.yaml 与 given_name_*.dict.yaml（通用汉字注音）
  4. 支持中文姓名生成 全拼、首拼、小鹤双拼 检索索引
--]]

local M = {}

-- 常用多音字及姓氏优先注音
local SURNAMES_SPECIAL = {
  ["曾"] = "zeng",
  ["单"] = "shan",
  ["解"] = "xie",
  ["仇"] = "qiu",
  ["朴"] = "piao",
  ["区"] = "ou",
  ["查"] = "zha",
  ["盖"] = "gai",
  ["繁"] = "po",
  ["缪"] = "miao",
  ["黑"] = "he",
  ["折"] = "she",
}

local surname_map = nil
local char_map = nil

-- 声调替换表
local TONE_MAP = {
  ["ā"] = "a", ["á"] = "a", ["ǎ"] = "a", ["à"] = "a",
  ["ō"] = "o", ["ó"] = "o", ["ǒ"] = "o", ["ò"] = "o",
  ["ē"] = "e", ["é"] = "e", ["ě"] = "e", ["è"] = "e",
  ["ī"] = "i", ["í"] = "i", ["ǐ"] = "i", ["ì"] = "i",
  ["ū"] = "u", ["ú"] = "u", ["ǔ"] = "u", ["ù"] = "u",
  ["ǖ"] = "v", ["ǘ"] = "v", ["ǚ"] = "v", ["ǜ"] = "v", ["ü"] = "v",
  ["ń"] = "en", ["ň"] = "en", ["ǹ"] = "en",
  ["ńg"] = "eng", ["ňg"] = "eng", ["ǹg"] = "eng",
}

function M.strip_tones(pinyin)
  if not pinyin then return "" end
  local s = pinyin:lower()
  for tone_ch, clean_ch in pairs(TONE_MAP) do
    s = s:gsub(tone_ch, clean_ch)
  end
  if s == "ng" then s = "eng" end
  return s
end

-- 全拼转小鹤双拼（严格对齐 double_pinyin_flypy.schema.yaml 拼写代数规则）
function M.pinyin_to_flypy(pinyin)
  if not pinyin or pinyin == "" then return "" end
  local s = M.strip_tones(pinyin)

  -- derive/^([jqxy])u$/$1v/
  s = s:gsub("^([jqxy])u$", "%1v")

  -- derive/^([aoe])([ioun])$/$1$1$2/
  s = s:gsub("^([aoe])([ioun])$", "%1%1%2")

  -- xform/^([aoe])(ng)?$/$1$1$2/
  s = s:gsub("^([aoe])(ng)?$", function(v, ng)
    return v .. v .. (ng or "")
  end)

  -- Finals
  s = s:gsub("iu$", "q")
  s = s:gsub("(.)ei$", "%1w")
  s = s:gsub("uan$", "r")
  s = s:gsub("[uv]e$", "t")
  -- 声母临时占位（与 Rime 拼写代数 circled letters 一致，避免影响后续韵母转换）
  s = s:gsub("^sh", "U")
  s = s:gsub("^ch", "I")
  s = s:gsub("^zh", "V")
  s = s:gsub("uo$", "o")
  s = s:gsub("ie$", "p")
  s = s:gsub("(.)i?ong$", "%1s")
  s = s:gsub("ing$", "k")
  s = s:gsub("uai$", "k")
  s = s:gsub("(.)ai$", "%1d")
  s = s:gsub("(.)en$", "%1f")
  s = s:gsub("(.)eng$", "%1g")
  s = s:gsub("[iu]ang$", "l")
  s = s:gsub("(.)ang$", "%1h")
  s = s:gsub("ian$", "m")
  s = s:gsub("(.)an$", "%1j")
  s = s:gsub("(.)ou$", "%1z")
  s = s:gsub("[iu]a$", "x")
  s = s:gsub("iao$", "n")
  s = s:gsub("(.)ao$", "%1c")
  s = s:gsub("ui$", "v")
  s = s:gsub("in$", "b")

  return s:lower()
end

local function get_dict_paths(filename)
  local user_dir = _G.rime_api and _G.rime_api.get_user_data_dir and _G.rime_api.get_user_data_dir() or ""
  local paths = {}
  if user_dir ~= "" then
    table.insert(paths, user_dir .. "/" .. filename)
    table.insert(paths, user_dir .. "/dicts/" .. filename)
    table.insert(paths, user_dir .. "/dicts/name/" .. filename)
  end
  table.insert(paths, filename)
  table.insert(paths, "dicts/" .. filename)
  table.insert(paths, "dicts/name/" .. filename)
  table.insert(paths, "Rime/" .. filename)
  table.insert(paths, "Rime/dicts/" .. filename)
  table.insert(paths, "Rime/dicts/name/" .. filename)
  return paths
end

local function open_first_available(paths)
  for _, p in ipairs(paths) do
    local f = io.open(p, "r")
    if f then return f, p end
  end
  return nil, nil
end

local function load_yaml_dict_lines(f, target_map)
  if not f then return end
  local in_data = false
  for line in f:lines() do
    local clean = line:match("[^\r\n]+")
    if clean then
      if clean == "..." then
        in_data = true
      elseif in_data and not clean:match("^#") then
        local ch, py = clean:match("^([^\t]+)\t([^\t]+)")
        if ch and py then
          -- 仅取单字映射
          local count = 0
          for _ in utf8.codes(ch) do count = count + 1 end
          if count == 1 and not target_map[ch] then
            target_map[ch] = M.strip_tones(py)
          end
        end
      end
    end
  end
  f:close()
end

function M.ensure_dict_loaded()
  if char_map then return end
  char_map = {}
  surname_map = {}

  -- 1. 预填核心姓氏多音字
  for ch, py in pairs(SURNAMES_SPECIAL) do
    surname_map[ch] = py
  end

  -- 2. 加载姓氏词库
  local sf, _ = open_first_available(get_dict_paths("surname.dict.yaml"))
  if sf then load_yaml_dict_lines(sf, surname_map) end

  -- 3. 加载常用名字单字词典
  local names_files = { "given_name_1.dict.yaml", "given_name_first.dict.yaml", "given_name_last.dict.yaml" }
  for _, nf in ipairs(names_files) do
    local f = open_first_available(get_dict_paths(nf))
    if f then load_yaml_dict_lines(f, char_map) end
  end

  -- 4. 加载通用字表 rime_mint.chars.dict.yaml
  local cf = open_first_available(get_dict_paths("rime_mint.chars.dict.yaml"))
  if cf then load_yaml_dict_lines(cf, char_map) end
end

function M.get_char_pinyin(ch, is_surname)
  M.ensure_dict_loaded()
  if is_surname and surname_map[ch] then
    return surname_map[ch]
  end
  if char_map[ch] then
    return char_map[ch]
  end
  if surname_map[ch] then
    return surname_map[ch]
  end
  return nil
end

function M.convert_name(name)
  if not name or name == "" then
    return {
      name = "",
      full_pinyin = "",
      initials = "",
      flypy = "",
    }
  end

  M.ensure_dict_loaded()

  local py_list = {}
  local fly_list = {}
  local init_list = {}
  local fly_init_list = {}

  local index = 0
  for _, cp in utf8.codes(name) do
    index = index + 1
    local ch = utf8.char(cp)
    local is_surname = (index == 1)

    if cp >= 0x4E00 and cp <= 0x9FFF or cp >= 0x3400 and cp <= 0x4DBF or cp >= 0x20000 then
      -- 中文字符
      local py = M.get_char_pinyin(ch, is_surname)
      if py and py ~= "" then
        local fly = M.pinyin_to_flypy(py)
        local init = py:sub(1, 1)
        local fly_init = fly:sub(1, 1)
        table.insert(py_list, py)
        table.insert(fly_list, fly)
        table.insert(init_list, init)
        table.insert(fly_init_list, fly_init)
      else
        -- 未知汉字，保留原字符占位
        table.insert(py_list, ch)
        table.insert(fly_list, ch)
        table.insert(init_list, ch)
        table.insert(fly_init_list, ch)
      end
    elseif cp >= 65 and cp <= 90 or cp >= 97 and cp <= 122 then
      -- 英文大小写
      local lower = string.char(cp):lower()
      table.insert(py_list, lower)
      table.insert(fly_list, lower)
      table.insert(init_list, lower)
      table.insert(fly_init_list, lower)
    elseif cp >= 48 and cp <= 57 then
      -- 数字
      local digit = string.char(cp)
      table.insert(py_list, digit)
      table.insert(fly_list, digit)
      table.insert(init_list, digit)
      table.insert(fly_init_list, digit)
    else
      -- 标点符号或空格忽略不计入拼音首拼与双拼检索编码
    end
  end

  return {
    name = name,
    full_pinyin = table.concat(py_list),
    initials = table.concat(init_list),
    flypy = table.concat(fly_list),
    flypy_initials = table.concat(fly_init_list),
  }
end

return M
