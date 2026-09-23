--[[
  hot_slot_filter.lua
  手心小鹤个人词库固定候选位、宏展开与高灵敏热加载滤镜

  功能特性：
  1. 读取普通文本词库 shouxin_flypy.txt（格式：编码=候选位,显示文本>上屏文本|注释::侧窗详情）；
  2. 严格保持固定候选位语义（数字表示候选位置，非权重，不扰乱未占位候选）；
  3. 宏展开语法：支持使用「>」或「＞」将候选词显示与实际上屏内容分离（如 dh=1,电话>138****4321）；
  4. 候选注释提示：支持使用「|」或「｜」添加右侧提示（如 a=4,A4|纸张大小），可与宏展开同时使用；
  5. 侧窗详情语法：支持使用「::」或「：：」添加详情，以「\n」表示换行，使用「**文字**」赋予强调色；
  6. 字符容错：全角/半角等号、逗号、竖线、大于号自动兼容，首尾空白自动 trim；
  7. 全内容极速比对热重载：检测文件变更（包括修改详情、注释、增删词条、单字变更），100% 无遗漏，保存即生效；
  8. 热加载安全保护：保存期间文件异常或为空时保留旧索引，确保无闪退与词库丢失；
  9. 重复候选处理：默认剔除与固定词条内容相同的后续原始候选；
  10. 特殊模式隔离：自动排除 emoji、lpr、计算器、人名模式等特殊输入状态。
--]]

local M = {}

-- 全局状态缓存（跨会话与实例共享，避免重复解析大词库）
M.slots = M.slots or {}
M.last_content = M.last_content or ""
M.last_check_time = M.last_check_time or 0
M.loaded_once = M.loaded_once or false
M.entry_count = M.entry_count or 0
M.code_count = M.code_count or 0
M.active_filepath = M.active_filepath or ""
M.active_commits = M.active_commits or {}
M.active_details = M.active_details or {}

local DETAIL_OWNER = "hot_slot"

-- 排除的特殊分词标签
local EXCLUDED_TAGS = {
  emoji = true,
  radical_lookup = true,
  calc_or_number = true,
  date_calc = true,
  law_article = true,
  law_unit = true,
  lpr = true,
  anyou = true,
  zuiming = true,
  fayuan = true,
  falv = true,
  history = true,
  url = true,
}

--------------------------------------------------------------------------------
-- 1. 文件路径解析（优先从用户数据目录解析）
--------------------------------------------------------------------------------
local function resolve_path(filename)
  filename = filename or "shouxin_flypy.txt"

  local user_dir = ""
  if _G.rime_api and _G.rime_api.get_user_data_dir then
    user_dir = _G.rime_api.get_user_data_dir()
  end

  local candidates = {}
  if user_dir ~= "" then
    table.insert(candidates, user_dir .. "/" .. filename)
    table.insert(candidates, user_dir .. "/dicts/flypy/" .. filename)
    table.insert(candidates, user_dir .. "/dicts/quanpin/" .. filename)
    table.insert(candidates, user_dir .. "/../" .. filename)
  end
  table.insert(candidates, filename)
  table.insert(candidates, "dicts/flypy/" .. filename)
  table.insert(candidates, "dicts/quanpin/" .. filename)
  table.insert(candidates, "Rime/" .. filename)
  table.insert(candidates, "Rime/dicts/flypy/" .. filename)
  table.insert(candidates, "Rime/dicts/quanpin/" .. filename)

  for _, path in ipairs(candidates) do
    local f = io.open(path, "r")
    if f then
      f:close()
      return path
    end
  end

  return filename
end

--------------------------------------------------------------------------------
-- 2. 多分隔符首位匹配辅助函数（兼容半角与全角符号）
--------------------------------------------------------------------------------
local function find_first_of(str, delims)
  local min_start, min_end = nil, nil
  for _, d in ipairs(delims) do
    local s, e = str:find(d, 1, true)
    if s and (not min_start or s < min_start) then
      min_start = s
      min_end = e
    end
  end
  return min_start, min_end
end

local function find_first_unescaped(str, delims)
  local search_from = 1
  while search_from <= #str do
    local min_start, min_end = nil, nil
    for _, d in ipairs(delims) do
      local s, e = str:find(d, search_from, true)
      if s and (not min_start or s < min_start) then
        min_start, min_end = s, e
      end
    end
    if not min_start then return nil, nil end
    if min_start == 1 or str:sub(min_start - 1, min_start - 1) ~= "\\" then
      return min_start, min_end
    end
    search_from = min_end + 1
  end
  return nil, nil
end

local function decode_detail(text)
  if not text or text == "" then return "" end
  return text:gsub("\\n", "\n"):gsub("\\::", "::"):gsub("\\：：", "：：")
end

--------------------------------------------------------------------------------
-- 3. 内存文本解析
--------------------------------------------------------------------------------
local function parse_content(content)
  local raw_map = {}
  local is_first_line = true

  for line in content:gmatch("[^\r\n]+") do
    local clean_line = line
    if is_first_line then
      is_first_line = false
      -- 剔除 UTF-8 BOM
      if clean_line:sub(1, 3) == "\239\187\191" then
        clean_line = clean_line:sub(4)
      end
    end

    -- 忽略空行与注释（支持 # 与 ;）
    local first_char = clean_line:match("^%s*(%S)")
    if first_char and first_char ~= "#" and first_char ~= ";" then
      local eq_s, eq_e = find_first_of(clean_line, { "=", "＝" })
      if eq_s then
        local raw_code = clean_line:sub(1, eq_s - 1)
        local code = raw_code:match("^%s*(.-)%s*$"):lower()

        local rest = clean_line:sub(eq_e + 1)
        local comma_s, comma_e = find_first_of(rest, { ",", "，" })
        if comma_s then
          local raw_pos = rest:sub(1, comma_s - 1)
          local pos_str = raw_pos:match("^%s*(.-)%s*$")
          local pos = tonumber(pos_str)
          local candidate_part = rest:sub(comma_e + 1)

          -- 正整数位置校验
          if pos and pos > 0 and math.floor(pos) == pos and #code > 0 then
            -- 1. 解析侧窗详情（兼容半角 :: 与全角 ：：）
            local detail = ""
            local main_candidate_part = candidate_part
            local detail_s, detail_e = find_first_unescaped(candidate_part, { "::", "：：" })
            if detail_s then
              main_candidate_part = candidate_part:sub(1, detail_s - 1)
              detail = candidate_part:sub(detail_e + 1):match("^%s*(.-)%s*$")
              detail = decode_detail(detail)
            end

            -- 2. 解析注释（兼容半角 | 与全角 ｜）
            local main_part = main_candidate_part
            local comment = ""
            local pipe_s, pipe_e = find_first_of(main_candidate_part, { "|", "｜" })
            if pipe_s then
              main_part = main_candidate_part:sub(1, pipe_s - 1)
              comment = main_candidate_part:sub(pipe_e + 1):match("^%s*(.-)%s*$")
            end

            -- 3. 解析宏展开实际上屏内容（兼容半角 > 与全角 ＞）
            local display_text = ""
            local commit_text = ""
            local gt_s, gt_e = find_first_of(main_part, { ">", "＞" })
            if gt_s then
              display_text = main_part:sub(1, gt_s - 1):match("^%s*(.-)%s*$")
              commit_text = main_part:sub(gt_e + 1):match("^%s*(.-)%s*$")
              if display_text == "" and commit_text ~= "" then
                display_text = commit_text
              end
            else
              display_text = main_part:match("^%s*(.-)%s*$")
              commit_text = display_text
            end

            if #display_text > 0 then
              local entry = raw_map[code]
              if not entry then
                entry = { slots = {}, commits = {}, comments = {}, details = {} }
                raw_map[code] = entry
              end
              -- 同编码同位置后出现的覆盖前面的
              entry.slots[pos] = display_text
              entry.commits[pos] = commit_text
              if comment and comment ~= "" then
                entry.comments[pos] = comment
              else
                entry.comments[pos] = nil
              end
              if detail and detail ~= "" then
                entry.details[pos] = detail
              else
                entry.details[pos] = nil
              end
            end
          else
            if _G.log and _G.log.warning then
              _G.log.warning(string.format("[hot_slot] Skip invalid line: %s", clean_line))
            end
          end
        end
      end
    end
  end

  -- 构建用于 O(1) 检索的高效结构
  local slots = {}
  local total_entries = 0
  local total_codes = 0

  for code, raw_entry in pairs(raw_map) do
    local texts = {}
    local commit_by_text = {}
    local max_pos = 0
    local count = 0
    local has_custom_commits = false
    local detail_by_text = {}

    for p, txt in pairs(raw_entry.slots) do
      texts[txt] = true
      local c_txt = raw_entry.commits[p] or txt
      commit_by_text[txt] = c_txt
      if c_txt ~= txt then
        has_custom_commits = true
      end
      local detail = raw_entry.details[p]
      if detail and detail ~= "" then
        detail_by_text[txt] = detail
      end
      if p > max_pos then max_pos = p end
      count = count + 1
      total_entries = total_entries + 1
    end

    slots[code] = {
      slots = raw_entry.slots,
      commits = raw_entry.commits,
      comments = raw_entry.comments,
      details = raw_entry.details,
      texts = texts,
      commit_by_text = commit_by_text,
      detail_by_text = detail_by_text,
      has_custom_commits = has_custom_commits,
      max_pos = max_pos,
      count = count,
    }
    total_codes = total_codes + 1
  end

  return slots, total_entries, total_codes
end

--------------------------------------------------------------------------------
-- 4. 多词库缓存与热加载执行
--------------------------------------------------------------------------------
M.file_caches = M.file_caches or {}

local function get_cache(filepath)
  filepath = filepath or M.active_filepath or ""
  if not M.file_caches[filepath] then
    M.file_caches[filepath] = {
      slots = {},
      last_content = "",
      last_check_time = 0,
      loaded_once = false,
      entry_count = 0,
      code_count = 0,
      active_commits = {},
      active_details = {},
    }
  end
  return M.file_caches[filepath]
end

local function reload_file(filepath, is_manual)
  filepath = filepath or M.active_filepath
  if not filepath or filepath == "" then return false end

  local cache = get_cache(filepath)
  local f = io.open(filepath, "r")
  if not f then
    if is_manual and _G.log and _G.log.error then
      _G.log.error("[hot_slot] Reload failed: file not accessible: " .. tostring(filepath))
    end
    return false
  end

  local content = f:read("*a")
  f:close()

  if not content or #content == 0 then
    if _G.log and _G.log.warning then
      _G.log.warning("[hot_slot] Reload failed (file invalid or empty), keeping old index")
    end
    return false
  end

  -- 全文本精准比对：注释、符号、词条任何微小变更均可 100% 感知（O(1) 字符串比对）
  if not is_manual and content == cache.last_content then
    return true
  end

  local new_slots, entries, codes = parse_content(content)
  if not new_slots or entries == 0 then
    if _G.log and _G.log.warning then
      _G.log.warning("[hot_slot] Parse yielded 0 entries, keeping old index")
    end
    return false
  end

  -- 更新指定文件缓存
  cache.slots = new_slots
  cache.last_content = content
  cache.entry_count = entries
  cache.code_count = codes
  cache.loaded_once = true
  cache.last_check_time = os.time()

  -- 同步更新全局兼容字段
  M.slots = new_slots
  M.last_content = content
  M.entry_count = entries
  M.code_count = codes
  M.active_filepath = filepath
  M.loaded_once = true

  if _G.log and _G.log.info then
    if is_manual or cache.loaded_once then
      _G.log.info(string.format("[hot_slot] %s changed, reloaded %d entries across %d codes", filepath, entries, codes))
    else
      _G.log.info(string.format("[hot_slot] Loaded %d entries across %d codes from %s", entries, codes, filepath))
    end
  end
  return true
end

--------------------------------------------------------------------------------
-- 5. 模块导出接口
--------------------------------------------------------------------------------
function M.reload(target_path)
  local path = target_path or M.active_filepath
  if not path or path == "" then
    path = resolve_path("shouxin_flypy.txt")
  end
  return reload_file(path, true)
end

_G.hot_slot = M

function M.init(env)
  local config = env.engine.schema.config
  local ns = env.name_space or "hot_slot_filter"
  ns = ns:gsub("^%*", "")

  local filename = config:get_string(ns .. "/file") or "shouxin_flypy.txt"
  env.filepath = resolve_path(filename)
  M.active_filepath = env.filepath

  env.check_interval = config:get_int(ns .. "/check_interval") or 1
  if env.check_interval < 1 then env.check_interval = 1 end

  local dedup = config:get_bool(ns .. "/deduplicate")
  env.deduplicate = (dedup == nil) and true or dedup

  env.enable_comments = config:get_bool(ns .. "/enable_comments") or false
  env.comment = config:get_string(ns .. "/comment") or ""
  env.cand_type = config:get_string(ns .. "/cand_type") or "hot_slot"

  env.cache = get_cache(env.filepath)
  if not env.cache.loaded_once then
    reload_file(env.filepath, false)
  end
end

--------------------------------------------------------------------------------
-- 6. Filter 核心逻辑（合并流）
--------------------------------------------------------------------------------
function M.func(input, env)
  local context = env.engine.context
  local filepath = env.filepath or M.active_filepath
  local cache = (env.filepath and get_cache(env.filepath)) or env.cache or get_cache(M.active_filepath)

  -- 低频检查热加载（默认最多每 1 秒检查一次）
  local now = os.time()
  local check_interval = env.check_interval or 1
  if (now - cache.last_check_time) >= check_interval then
    cache.last_check_time = now
    reload_file(filepath, false)
  end

  local composition = context.composition
  if composition:empty() then
    for cand in input:iter() do yield(cand) end
    return
  end

  local segment = composition:back()
  if not segment then
    for cand in input:iter() do yield(cand) end
    return
  end

  -- 特殊模式与人名模式隔离：仅作用于普通中文输入段落
  if not segment:has_tag("abc") then
    for cand in input:iter() do yield(cand) end
    return
  end

  for tag in pairs(EXCLUDED_TAGS) do
    if segment:has_tag(tag) then
      for cand in input:iter() do yield(cand) end
      return
    end
  end

  if context:get_option("name_mode") then
    for cand in input:iter() do yield(cand) end
    return
  end

  local tab_mode = (context.get_property and context:get_property("tab_mode")) or ""
  if tab_mode ~= "" then
    for cand in input:iter() do yield(cand) end
    return
  end

  -- 提取当前 segment 输入编码
  local raw_input = context.input or ""
  if segment.start < 0 or segment._end > #raw_input or segment.start >= segment._end then
    for cand in input:iter() do yield(cand) end
    return
  end

  local raw_code = raw_input:sub(segment.start + 1, segment._end)
  -- 包含大写字母时（如各种功能前缀或大写输入），不参与普通双拼固定候选槽位匹配
  if raw_code:find("%u") then
    for cand in input:iter() do yield(cand) end
    return
  end

  local code = raw_code:lower()
  local slot_entry = cache.slots[code] or M.slots[code]

  -- 未命中固定槽位时，零额外开销透传
  if not slot_entry then
    for cand in input:iter() do yield(cand) end
    return
  end

  local deduplicate = env.deduplicate
  local cand_type = env.cand_type
  local default_comment = env.enable_comments and env.comment or ""

  -- 重置当前输入编码下的实际提交映射
  cache.active_commits = {}
  cache.active_details = {}
  M.active_commits = cache.active_commits
  M.active_details = cache.active_details

  -- 单次创建原始候选流迭代器并按需单向拉取
  local iter_func, iter_state, iter_var = input:iter()
  local function next_raw_cand()
    if iter_state ~= nil then
      iter_var = iter_func(iter_state, iter_var)
      return iter_var
    else
      return iter_func()
    end
  end

  -- 原始候选流拉取器（自动过滤与固定词条内容相同的项）
  local function get_next_cand()
    while true do
      local cand = next_raw_cand()
      if not cand then return nil end
      if not (deduplicate and slot_entry.texts[cand.text]) then
        return cand
      end
    end
  end

  local pos = 0
  local max_pos = slot_entry.max_pos
  local unyielded_slots_count = slot_entry.count
  local output_idx = 0

  local function yield_slot_candidate(p, text)
    local slot_comment = (slot_entry.comments and slot_entry.comments[p]) or default_comment
    local slot_commit = (slot_entry.commits and slot_entry.commits[p]) or text
    if slot_commit ~= text then
      cache.active_commits[output_idx] = slot_commit
      M.active_commits[output_idx] = slot_commit
    end
    local slot_detail = slot_entry.details and slot_entry.details[p] or ""
    if slot_detail ~= "" then
      cache.active_details[output_idx] = slot_detail
      M.active_details[output_idx] = slot_detail
    end
    local scand = Candidate(cand_type, segment.start, segment._end, text, slot_comment)
    yield(scand)
    output_idx = output_idx + 1
  end

  while true do
    pos = pos + 1
    local slot_text = slot_entry.slots[pos]

    if slot_text then
      yield_slot_candidate(pos, slot_text)
      unyielded_slots_count = unyielded_slots_count - 1
    else
      local orig_cand = get_next_cand()
      if orig_cand then
        yield(orig_cand)
        output_idx = output_idx + 1
      else
        -- 原始候选已耗尽：若仍有尚未输出的更高位槽位，按槽位升序补齐
        if unyielded_slots_count > 0 then
          for p = pos + 1, max_pos do
            local remaining_text = slot_entry.slots[p]
            if remaining_text then
              yield_slot_candidate(p, remaining_text)
            end
          end
        end
        break
      end
    end

    -- 若已超过最大槽位且所有槽位均已输出，进入快速直通通道
    if pos >= max_pos and unyielded_slots_count <= 0 then
      while true do
        local cand = get_next_cand()
        if not cand then break end
        yield(cand)
        output_idx = output_idx + 1
      end
      break
    end
  end
end

function M.fini(env)
end

--------------------------------------------------------------------------------
-- 7. Processor 核心逻辑（选词拦截与宏展开文本上屏）
--------------------------------------------------------------------------------
local kAccepted = 1
local kNoop = 2

M.processor = {}

local function clear_owned_detail(context)
  if (context:get_property("candidate_detail_owner") or "") == DETAIL_OWNER then
    context:set_property("candidate_detail", "")
    context:set_property("candidate_detail_owner", "")
  end
end

local function sync_detail(context, env)
  if not context:is_composing() or not context:has_menu() then
    clear_owned_detail(context)
    return
  end

  local composition = context.composition
  local seg = composition and not composition:empty() and composition:back() or nil
  if not seg or not seg:has_tag("abc") or context:get_option("name_mode") then
    clear_owned_detail(context)
    return
  end
  for tag in pairs(EXCLUDED_TAGS) do
    if seg:has_tag(tag) then
      clear_owned_detail(context)
      return
    end
  end
  if (context:get_property("tab_mode") or "") ~= "" then
    clear_owned_detail(context)
    return
  end

  local raw_input = context.input or ""
  if seg.start < 0 or seg._end > #raw_input or seg.start >= seg._end then
    clear_owned_detail(context)
    return
  end
  local code = raw_input:sub(seg.start + 1, seg._end):lower()
  local cache = (env.filepath and get_cache(env.filepath)) or env.cache or get_cache(M.active_filepath)
  local slot_entry = cache.slots[code] or M.slots[code]
  if not slot_entry then
    clear_owned_detail(context)
    return
  end

  local cand = context.get_selected_candidate and context:get_selected_candidate() or nil
  if not cand and seg.get_selected_candidate then cand = seg:get_selected_candidate() end
  local sel_idx = seg.selected_index or 0
  local active_details = cache.active_details or M.active_details or {}
  local detail = active_details[sel_idx]
    or (cand and slot_entry.detail_by_text and slot_entry.detail_by_text[cand.text])
    or ""

  if detail ~= "" then
    if (context:get_property("candidate_detail") or "") ~= detail then
      context:set_property("candidate_detail", detail)
    end
    context:set_property("candidate_detail_owner", DETAIL_OWNER)
  else
    clear_owned_detail(context)
  end
end

function M.processor.init(env)
  local config = env.engine.schema.config
  env.page_size = config:get_int("menu/page_size") or 5

  local ns = env.name_space or "hot_slot_filter"
  ns = ns:gsub("^%*", "")
  local filename = config:get_string(ns .. "/file")
    or config:get_string("hot_slot_filter/file")
    or "shouxin_flypy.txt"
  env.filepath = resolve_path(filename)
  env.cache = get_cache(env.filepath)

  -- 兜底监听选词通知（主要覆盖鼠标点击候选词场景）
  local context = env.engine.context
  env.update_connection = context.update_notifier:connect(function(ctx)
    sync_detail(ctx, env)
  end)
  env.select_connection = context.select_notifier:connect(function(ctx)
    sync_detail(ctx, env)
    if not ctx:is_composing() then return end
    local composition = ctx.composition
    if not composition or composition:empty() then return end
    local seg = composition:back()
    if not seg then return end

    local cand = ctx:get_selected_candidate()
    if not cand then return end

    local raw_input = ctx.input or ""
    if seg.start < 0 or seg._end > #raw_input or seg.start >= seg._end then return end
    local code = raw_input:sub(seg.start + 1, seg._end):lower()
    local cache = (env.filepath and get_cache(env.filepath)) or env.cache or get_cache(M.active_filepath)
    local slot_entry = cache.slots[code] or M.slots[code]
    if not slot_entry or not slot_entry.has_custom_commits then return end

    local sel_idx = seg.selected_index or 0
    local custom_commit = (cache.active_commits and cache.active_commits[sel_idx])
      or (M.active_commits and M.active_commits[sel_idx])
      or slot_entry.commit_by_text[cand.text]
      or slot_entry.commits[sel_idx + 1]

    if custom_commit and custom_commit ~= cand.text then
      local genuine = (cand.get_genuine and cand:get_genuine()) or cand
      genuine.text = custom_commit
    end
  end)
end

function M.processor.fini(env)
  if env.update_connection then
    env.update_connection:disconnect()
    env.update_connection = nil
  end
  if env.select_connection then
    env.select_connection:disconnect()
    env.select_connection = nil
  end
  local context = env.engine and env.engine.context
  if context then clear_owned_detail(context) end
end

function M.processor.func(key, env)
  if key:release() then return kNoop end
  if key:ctrl() or key:alt() or key:super() then return kNoop end

  local context = env.engine.context
  if not context:is_composing() or not context:has_menu() then
    return kNoop
  end

  local composition = context.composition
  if not composition or composition:empty() then return kNoop end
  local seg = composition:back()
  if not seg or not seg:has_tag("abc") then return kNoop end

  for tag in pairs(EXCLUDED_TAGS) do
    if seg:has_tag(tag) then return kNoop end
  end

  if context:get_option("name_mode") then return kNoop end
  local tab_mode = (context.get_property and context:get_property("tab_mode")) or ""
  if tab_mode ~= "" then return kNoop end

  local raw_input = context.input or ""
  if seg.start < 0 or seg._end > #raw_input or seg.start >= seg._end then return kNoop end
  local raw_code = raw_input:sub(seg.start + 1, seg._end)
  if raw_code:find("%u") then return kNoop end

  local code = raw_code:lower()
  local cache = (env.filepath and get_cache(env.filepath)) or env.cache or get_cache(M.active_filepath)
  local slot_entry = cache.slots[code] or M.slots[code]
  if not slot_entry or not slot_entry.has_custom_commits then
    return kNoop
  end

  local repr = key:repr() or ""
  local page_size = env.page_size or 5
  local sel_index = seg.selected_index or 0
  local page_start = math.floor(sel_index / page_size) * page_size
  local target_index = nil

  if repr == "space" or repr == "Space" then
    target_index = sel_index
  elseif repr:match("^[1-9]$") then
    local num = tonumber(repr)
    if num <= page_size then
      target_index = page_start + (num - 1)
    end
  elseif repr:match("^KP_([1-9])$") then
    local num = tonumber(repr:match("^KP_([1-9])$"))
    if num <= page_size then
      target_index = page_start + (num - 1)
    end
  elseif repr == "semicolon" or repr == ";" then
    target_index = page_start + 1
  elseif repr == "apostrophe" or repr == "'" then
    target_index = page_start + 2
  end

  if not target_index then
    return kNoop
  end

  local target_commit = (cache.active_commits and cache.active_commits[target_index])
    or (M.active_commits and M.active_commits[target_index])
  local menu = seg.menu
  local target_cand = (menu and not menu:empty() and target_index < menu:candidate_count())
    and menu:get_candidate_at(target_index) or nil

  if not target_commit and target_cand then
    target_commit = slot_entry.commit_by_text[target_cand.text]
  end
  if not target_commit then
    target_commit = slot_entry.commits[target_index + 1]
  end

  -- 若该候选包含宏展开（commit_text ~= display_text），拦截并直接上屏
  if target_commit and (not target_cand or target_commit ~= target_cand.text) then
    local prefix = ""
    if seg.start > 0 and context.get_commit_text then
      prefix = context:get_commit_text() or ""
    end
    env.engine:commit_text(prefix .. target_commit)
    context:clear()
    return kAccepted
  end

  return kNoop
end

return M
