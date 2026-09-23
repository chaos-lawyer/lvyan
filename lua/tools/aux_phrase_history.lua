--[[
  小鹤逐字辅码词组学习。

  Rime 的原生用户词典会学习正常的连续选词；但逐字用辅码缩小候选时，
  输入码中混入的辅码（如 ciyzus）不能直接作为词组的双拼码（cizu）保存。
  本模块仅处理「每个汉字恰好附带一位有效辅码」的提交，将其作为独立的
  基础双拼词组记录，供下次直接输入基础码时优先候选。
--]]

local M = {}

M.entries = {}
M.loaded = false

local function user_dict_path()
  local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
  return user_dir ~= "" and (user_dir .. "/aux_phrase_history.txt") or "aux_phrase_history.txt"
end

local function count_cjk(text)
  local count = 0
  for _, cp in utf8.codes(text or "") do
    if (cp >= 0x3400 and cp <= 0x4DBF) or (cp >= 0x4E00 and cp <= 0x9FFF)
        or (cp >= 0xF900 and cp <= 0xFAFF) or (cp >= 0x20000 and cp <= 0x2EBEF)
        or (cp >= 0x30000 and cp <= 0x323AF) then
      count = count + 1
    else
      return nil
    end
  end
  return count
end

local function load_aux_initials()
  local initials = {}
  local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
  local file = io.open(user_dir .. "/lua/aux_code/flypy_full.txt", "r")
      or io.open("lua/aux_code/flypy_full.txt", "r")
  if not file then return initials end

  for line in file:lines() do
    local char, codes = line:match("^([^=]+)=(.+)$")
    if char and codes then
      local set = initials[char] or {}
      for code in codes:gmatch("%S+") do
        if #code > 0 then set[code:sub(1, 1)] = true end
      end
      initials[char] = set
    end
  end
  file:close()
  return initials
end

local function load_entries()
  if M.loaded then return end
  M.entries = {}
  local file = io.open(user_dict_path(), "r")
  if file then
    for line in file:lines() do
      if not line:match("^#") then
        local code, text, count, time = line:match("^([^\t]+)\t([^\t]+)\t(%d+)\t(%d+)$")
        if code and text then
          M.entries[code] = M.entries[code] or {}
          table.insert(M.entries[code], {
            text = text, count = tonumber(count) or 1, last_time = tonumber(time) or 0,
          })
        end
      end
    end
    file:close()
  end
  M.loaded = true
end

local function sort_entries(entries)
  table.sort(entries, function(a, b)
    if a.count == b.count then return a.last_time > b.last_time end
    return a.count > b.count
  end)
end

local function save_entries()
  local file = io.open(user_dict_path(), "w")
  if not file then return end
  file:write("# Rime 小鹤逐字辅码词组学习\n# code\ttext\tcount\tlast_time\n")
  local codes = {}
  for code in pairs(M.entries) do table.insert(codes, code) end
  table.sort(codes)
  for _, code in ipairs(codes) do
    sort_entries(M.entries[code])
    for _, entry in ipairs(M.entries[code]) do
      file:write(string.format("%s\t%s\t%d\t%d\n", code, entry.text, entry.count, entry.last_time))
    end
  end
  file:close()
end

-- 输入必须正好是「每字两码双拼 + 一位有效辅码」；返回去掉辅码后的基础码。
function M.base_code_from_aux_commit(input, text, aux_initials)
  local chars = {}
  for _, cp in utf8.codes(text or "") do table.insert(chars, utf8.char(cp)) end
  local char_count = count_cjk(text)
  if not char_count or char_count < 2 or char_count > 6 or #chars ~= char_count then return nil end
  if not input or not input:match("^[a-z]+$") or #input ~= char_count * 3 then return nil end

  local base = {}
  for i, char in ipairs(chars) do
    local offset = (i - 1) * 3
    local aux = input:sub(offset + 3, offset + 3)
    if not (aux_initials[char] and aux_initials[char][aux]) then return nil end
    base[#base + 1] = input:sub(offset + 1, offset + 2)
  end
  return table.concat(base)
end

local function record(code, text)
  load_entries()
  local entries = M.entries[code] or {}
  M.entries[code] = entries
  local now = os.time()
  for _, entry in ipairs(entries) do
    if entry.text == text then
      entry.count = entry.count + 1
      entry.last_time = now
      save_entries()
      return
    end
  end
  table.insert(entries, { text = text, count = 1, last_time = now })
  save_entries()
end

M.processor = {}

function M.processor.init(env)
  env.aux_initials = load_aux_initials()
  local context = env.engine.context
  env.commit_connection = context.commit_notifier:connect(function(ctx)
    local input = ctx.input or ""
    local text = ctx.get_commit_text and ctx:get_commit_text() or ""
    local code = M.base_code_from_aux_commit(input, text, env.aux_initials)
    if code then record(code, text) end
  end)
end

function M.processor.fini(env)
  if env.commit_connection then env.commit_connection:disconnect() end
  env.commit_connection = nil
  env.aux_initials = nil
end

function M.translator(input, seg, _)
  if not input:match("^[a-z]+$") or #input < 4 or #input % 2 ~= 0 then return end
  load_entries()
  local entries = M.entries[input]
  if not entries then return end
  sort_entries(entries)
  for index, entry in ipairs(entries) do
    local cand = Candidate("aux_phrase_history", seg.start, seg._end, entry.text, "〔辅码学习〕")
    cand.quality = 1000000 + entry.count * 100 - index
    yield(cand)
  end
end

return M
