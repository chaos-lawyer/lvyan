--[[
  user_initials_history.lua
  小鹤双拼自造词首拼（声母）自动学习与候选召回模块。

  功能说明：
  1. 学习记录（Processor）：
     - 监听 context.commit_notifier 上屏事件；
     - 当用户在双拼模式下一次性上屏 3~8 个纯中文字符时：
       * 若输入码正好为每字两码的双拼序列（#input == char_count * 2），自动提取各字的声母键（奇数位字母）组成首拼；
       * 若输入码为每字三码的辅码序列（#input == char_count * 3），自动提取每字第一键组成首拼；
       * 若输入码为首拼（#input == char_count），强化该首拼词条词频；
     - 将首拼与词条持久化存储至 user_initials_history.txt。
  2. 候选输出（Translator）：
     - 当输入 3~8 位纯字母（如 kdlr）且匹配已学条目时，输出候选词；
     - 候选项不附加任何注释/标记（comment 为空字符串）。
--]]

local M = {}

M.entries = {}
M.loaded = false

-- 获取存储文件路径
function M.user_dict_path()
  local user_dir = _G.rime_api and _G.rime_api.get_user_data_dir and _G.rime_api.get_user_data_dir() or ""
  if user_dir ~= "" then
    return user_dir .. "/user_initials_history.txt"
  end
  local f = io.open("Rime/user_initials_history.txt", "r")
  if f then
    f:close()
    return "Rime/user_initials_history.txt"
  end
  return "user_initials_history.txt"
end

-- 统计纯中文字符数（3~8字）
function M.count_cjk(text)
  if not text or text == "" then return nil end
  local count = 0
  for _, cp in utf8.codes(text) do
    if (cp >= 0x3400 and cp <= 0x4DBF) or (cp >= 0x4E00 and cp <= 0x9FFF)
        or (cp >= 0xF900 and cp <= 0xFAFF) or (cp >= 0x20000 and cp <= 0x2EBEF)
        or (cp >= 0x30000 and cp <= 0x323AF) then
      count = count + 1
    else
      return nil -- 含有非汉字字符，不参与首拼学习
    end
  end
  return count
end

-- 加载词典数据
function M.load_entries()
  if M.loaded then return end
  M.entries = {}
  local path = M.user_dict_path()
  local file = io.open(path, "r")
  if not file then
    file = io.open("Rime/user_initials_history.txt", "r") or io.open("user_initials_history.txt", "r")
  end
  if file then
    for line in file:lines() do
      local clean = line:match("[^\r\n]+")
      if clean and not clean:match("^#") then
        local code, text, count, time = clean:match("^([^\t]+)\t([^\t]+)\t?(%d*)\t?(%d*)")
        if code and text then
          M.entries[code] = M.entries[code] or {}
          table.insert(M.entries[code], {
            text = text,
            count = tonumber(count) or 1,
            last_time = tonumber(time) or 0,
          })
        end
      end
    end
    file:close()
  end
  M.loaded = true
end

-- 排序词条：词频优先，次看最新上屏时间
function M.sort_entries(entries)
  table.sort(entries, function(a, b)
    if a.count == b.count then
      return (a.last_time or 0) > (b.last_time or 0)
    end
    return (a.count or 0) > (b.count or 0)
  end)
end

-- 保存词典数据
function M.save_entries()
  local path = M.user_dict_path()
  local file = io.open(path, "w")
  if not file then return end
  file:write("# Rime user_initials_history\n# code\ttext\tcount\tlast_time\n")
  local codes = {}
  for code in pairs(M.entries) do
    table.insert(codes, code)
  end
  table.sort(codes)
  for _, code in ipairs(codes) do
    M.sort_entries(M.entries[code])
    for _, entry in ipairs(M.entries[code]) do
      file:write(string.format("%s\t%s\t%d\t%d\n", code, entry.text, entry.count, entry.last_time))
    end
  end
  file:close()
end

-- 记录或更新词条
function M.record(code, text)
  if not code or not text or code == "" or text == "" then return end
  M.load_entries()
  local entries = M.entries[code] or {}
  M.entries[code] = entries
  local now = os.time()
  for _, entry in ipairs(entries) do
    if entry.text == text then
      entry.count = entry.count + 1
      entry.last_time = now
      M.save_entries()
      return
    end
  end
  table.insert(entries, { text = text, count = 1, last_time = now })
  M.save_entries()
end

-- 从双拼或辅码输入中提取小鹤首拼
function M.extract_initials(input, char_count)
  if not input or not char_count then return nil end
  local clean = input:lower():gsub("[^a-z]", "")

  if #clean == char_count * 2 then
    -- 每字两键双拼，提取奇数位
    local chars = {}
    for i = 1, char_count do
      chars[#chars + 1] = clean:sub((i - 1) * 2 + 1, (i - 1) * 2 + 1)
    end
    return table.concat(chars)
  elseif #clean == char_count * 3 then
    -- 每字两键双拼 + 一键辅码，提取每字第一键
    local chars = {}
    for i = 1, char_count do
      chars[#chars + 1] = clean:sub((i - 1) * 3 + 1, (i - 1) * 3 + 1)
    end
    return table.concat(chars)
  elseif #clean == char_count then
    -- 已是首拼输入
    return clean
  end

  return nil
end

M.processor = {}

function M.processor.init(env)
  local context = env.engine.context
  env.commit_connection = context.commit_notifier:connect(function(ctx)
    local input = ctx.input or ""
    local text = ctx.get_commit_text and ctx:get_commit_text() or ""
    local tab_mode = ctx:get_property("tab_mode") or ""
    -- 排除 Tab 引导的功能模式
    if tab_mode and tab_mode ~= "" then return end

    local char_count = M.count_cjk(text)
    if not char_count or char_count < 3 or char_count > 8 then return end

    local code = M.extract_initials(input, char_count)
    if code and #code >= 3 and #code <= 8 then
      M.record(code, text)
    end
  end)
end

function M.processor.func(key_event, env)
  return 2 -- 2 为 kNoop
end

function M.processor.fini(env)
  if env.commit_connection then
    env.commit_connection:disconnect()
    env.commit_connection = nil
  end
end

function M.translator(input, seg, env)
  if not input:match("^[a-z]+$") then return end
  local len = #input
  if len < 3 or len > 8 then return end

  M.load_entries()
  local entries = M.entries[input]
  if not entries or #entries == 0 then return end

  M.sort_entries(entries)
  for index, entry in ipairs(entries) do
    -- 用户要求：候选项不带标记，comment 设置为空字符串 ""
    local cand = Candidate("user_initials", seg.start, seg._end, entry.text, "")
    cand.quality = 1000 + (entry.count or 1) * 10 - index
    yield(cand)
  end
end

return M
