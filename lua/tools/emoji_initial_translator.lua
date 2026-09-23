-- Emoji 表情模式（内部 E 前缀）的小鹤首拼索引。
-- 从手心小鹤词库读取双拼码，按每两个键取第一个键：uuji -> uj，haha -> hh。

local MAX_CANDIDATES = 80
local index
local PREFERRED = {
  hh = { "哈哈" },
  uj = { "书籍" },
}

local function load_emoji_words()
  local user_dir = _G.rime_api and _G.rime_api.get_user_data_dir and _G.rime_api.get_user_data_dir() or ""
  local paths = {}
  if user_dir ~= "" then
    table.insert(paths, user_dir .. "/opencc/emoji.txt")
  end
  table.insert(paths, "Rime/opencc/emoji.txt")
  table.insert(paths, "opencc/emoji.txt")

  local file = nil
  for _, path in ipairs(paths) do
    file = io.open(path, "r")
    if file then break end
  end
  if not file then
    return {}
  end

  local words = {}
  for line in file:lines() do
    local text = line:match("^([^\t]+)\t")
    if text then
      words[text] = true
    end
  end
  file:close()
  return words
end

local function build_index()
  local user_dir = _G.rime_api and _G.rime_api.get_user_data_dir and _G.rime_api.get_user_data_dir() or ""
  local candidates = {}
  if user_dir ~= "" then
    table.insert(candidates, user_dir .. "/dicts/flypy/shouxin_flypy.txt")
    table.insert(candidates, user_dir .. "/shouxin_flypy.txt")
    table.insert(candidates, user_dir .. "/shouxin_flypy.dict.yaml")
    table.insert(candidates, user_dir .. "/../shouxin_flypy.txt")
  end
  table.insert(candidates, "Rime/dicts/flypy/shouxin_flypy.txt")
  table.insert(candidates, "dicts/flypy/shouxin_flypy.txt")
  table.insert(candidates, "Rime/shouxin_flypy.txt")
  table.insert(candidates, "shouxin_flypy.txt")
  table.insert(candidates, "Rime/shouxin_flypy.dict.yaml")
  table.insert(candidates, "shouxin_flypy.dict.yaml")

  local file = nil
  for _, path in ipairs(candidates) do
    file = io.open(path, "r")
    if file then break end
  end
  if not file then
    return {}
  end

  local emoji_words = load_emoji_words()
  local result = {}
  for line in file:lines() do
    local clean_line = line:gsub("[\r\n]+$", "")
    local text, code
    local c, p, t = clean_line:match("^([a-z]+)%s*=%s*(%d+)%s*,%s*(.+)$")
    if c and t then
      local detail_pos = t:find("::", 1, true) or t:find("：：", 1, true)
      if detail_pos then
        t = t:sub(1, detail_pos - 1)
      end
      local pipe_pos = t:find("|", 1, true) or t:find("｜", 1, true)
      if pipe_pos then
        t = t:sub(1, pipe_pos - 1)
      end
      local gt_pos = t:find(">", 1, true) or t:find("＞", 1, true)
      if gt_pos then
        t = t:sub(1, gt_pos - 1)
      end
      code, text = c, t:match("^%s*(.-)%s*$")
    else
      text, code = clean_line:match("^([^\t]+)\t([a-z]+)\t")
    end

    if text and code and emoji_words[text] and #code >= 4 and #code % 2 == 0 then
      local initial = code:gsub("(.).", "%1")
      if #initial >= 2 then
        local entries = result[initial]
        if not entries then
          entries = { values = {}, seen = {} }
          result[initial] = entries
        end
        if not entries.seen[text] and #entries.values < MAX_CANDIDATES then
          entries.seen[text] = true
          table.insert(entries.values, text)
        end
      end
    end
  end
  file:close()
  return result
end

local function translator(input, seg, env)
  if not seg:has_tag("emoji") or #input < 2 then
    return
  end
  local code = input

  if not index then
    index = build_index()
  end
  local entries = index[code]
  local yielded = {}

  for _, text in ipairs(PREFERRED[code] or {}) do
    local candidate = Candidate("emoji_initial", seg.start, seg._end, text, "小鹤首拼")
    candidate.quality = 1000000
    yield(candidate)
    yielded[text] = true
  end

  if entries then
    for _, text in ipairs(entries.values) do
      if not yielded[text] then
        local candidate = Candidate("emoji_initial", seg.start, seg._end, text, "小鹤首拼")
        candidate.quality = 999999
        yield(candidate)
      end
    end
  end
end

return translator
