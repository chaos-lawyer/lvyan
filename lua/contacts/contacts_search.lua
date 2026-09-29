--[[
  contacts_search.lua
  通讯录检索与多维度候选排序引擎：
  1. 支持 中文姓名、全拼、首拼、小鹤双拼、电话号码 检索
  2. 严格按需求优先级分层排序：
     姓名完全匹配 > 拼音完全匹配 > 首拼完全匹配 > 小鹤双拼完全匹配 >
     前缀匹配 > 包含匹配 > 电话号码匹配
  3. 同级候选保持 contacts.csv 原始先后次序
  4. 支持同名联系人（通过零宽字符消歧防止 Rime uniquifier 滤镜误删）
  5. 维护当前检索会话的 candidate_index -> commit_value 映射
--]]

local loader = require("contacts_loader")

local M = {}

-- 当前会话候选提交值缓存（0-indexed）
M.active_commits = {}

local function escape_pattern(text)
  return text:gsub("([%(%)%.%%%+%-%*%?%[%^%$%]])", "%%%1")
end

local function match_rank(item, q, esc_q, is_flypy)
  local name_lower = item.name:lower()
  local phone = item.commit_value or ""

  -- 1. 姓名完全匹配（全拼/双拼通用）
  if name_lower == q then return 1 end

  if is_flypy then
    -- 双拼模式：完全关闭全拼检索，仅使用双拼全码与双拼首字母
    local fly = item.flypy or ""
    local fly_init = item.flypy_initials or ""

    -- 2. 双拼全码完全匹配 (如 vhsj -> 张三)
    if fly ~= "" and fly == q then return 2 end
    -- 3. 双拼首字母完全匹配 (如 vs -> 张三)
    if fly_init ~= "" and fly_init == q then return 3 end

    -- 4. 前缀匹配
    if name_lower:find("^" .. esc_q) then return 4 end
    if fly_init ~= "" and fly_init:find("^" .. esc_q) then return 5 end
    if fly ~= "" and fly:find("^" .. esc_q) then return 6 end

    -- 5. 包含匹配
    if name_lower:find(esc_q, 1, true) then return 7 end
    if fly_init ~= "" and fly_init:find(esc_q, 1, true) then return 8 end
    if fly ~= "" and fly:find(esc_q, 1, true) then return 9 end
  else
    -- 全拼模式：完全关闭双拼检索，仅使用全拼全码与全拼首字母
    local py = item.full_pinyin or ""
    local init = item.initials or ""

    -- 2. 全拼全码完全匹配 (如 zhangsan -> 张三)
    if py ~= "" and py == q then return 2 end
    -- 3. 全拼首字母完全匹配 (如 zs -> 张三)
    if init ~= "" and init == q then return 3 end

    -- 4. 前缀匹配
    if name_lower:find("^" .. esc_q) then return 4 end
    if init ~= "" and init:find("^" .. esc_q) then return 5 end
    if py ~= "" and py:find("^" .. esc_q) then return 6 end

    -- 5. 包含匹配
    if name_lower:find(esc_q, 1, true) then return 7 end
    if init ~= "" and init:find(esc_q, 1, true) then return 8 end
    if py ~= "" and py:find(esc_q, 1, true) then return 9 end
  end

  return nil
end

function M.search(query, max_count, pinyin_type)
  max_count = max_count or 40
  local is_flypy = (pinyin_type == "flypy")
  M.active_commits = {}

  local entries, err = loader.load_contacts(false)
  if err or not entries or #entries == 0 then
    return {}, err
  end

  local q = (query or ""):lower():gsub("^%s*(.-)%s*$", "%1")

  local matched = {}
  if q == "" then
    for i, item in ipairs(entries) do
      if i > max_count then break end
      table.insert(matched, { item = item, rank = 100, id = item.id })
    end
  else
    local esc_q = escape_pattern(q)
    for _, item in ipairs(entries) do
      local rank = match_rank(item, q, esc_q, is_flypy)
      if rank then
        table.insert(matched, {
          item = item,
          rank = rank,
          id = item.id,
        })
      end
    end

    table.sort(matched, function(a, b)
      if a.rank ~= b.rank then
        return a.rank < b.rank
      end
      return a.id < b.id
    end)
  end

  local results = {}
  local name_seen_count = {}

  local limit = math.min(#matched, max_count)
  for i = 1, limit do
    local item = matched[i].item
    local name = item.name

    local seen = name_seen_count[name] or 0
    name_seen_count[name] = seen + 1

    -- 同名联系人使用零宽空格 (U+200B) 消歧，避免 Rime uniquifier 丢弃
    local cand_text = name
    if seen > 0 then
      cand_text = name .. string.rep("\xE2\x80\x8B", seen)
    end

    local cand_index = i - 1 -- Rime menu 0-indexed
    M.active_commits[cand_index] = item.commit_value

    table.insert(results, {
      index = cand_index,
      text = cand_text,
      comment = item.comment,
      commit_value = item.commit_value,
      name = item.name,
    })
  end

  return results, nil
end

function M.get_commit_value(index)
  if index and M.active_commits then
    return M.active_commits[index]
  end
  return nil
end

return M
