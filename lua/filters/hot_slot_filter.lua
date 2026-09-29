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
  10. 特殊模式隔离：自动排除 emoji、lpr、计算器、人名模式等特殊输入状态；
  11. 手心输入法动态时间/日期函数：支持以 # 开头配合 $(函数) 变量动态求值系统当前时间、日期、星期及农历（如 #$(year)年、#$(YYYY)年、#$(year_cn)年、#$(month_mm)月、#$(day_dd)日、#$(week_cn) 等）。
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
-- 3. 手心输入法风格动态时间/日期函数宏解析
--------------------------------------------------------------------------------
local CN_DIGITS = { ["0"]="〇", ["1"]="一", ["2"]="二", ["3"]="三", ["4"]="四", ["5"]="五", ["6"]="六", ["7"]="七", ["8"]="八", ["9"]="九" }
local CN_MONTHS = { "一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二" }
local CN_DAYS = {
  "一", "二", "三", "四", "五", "六", "七", "八", "九", "十",
  "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
  "二十一", "二十二", "二十三", "二十四", "二十五", "二十六", "二十七", "二十八", "二十九", "三十", "三十一"
}
local CN_WEEKS = { [0]="星期日", [1]="星期一", [2]="星期二", [3]="星期三", [4]="星期四", [5]="星期五", [6]="星期六" }
local CN_WEEKDAYS = { [0]="周日", [1]="周一", [2]="周二", [3]="周三", [4]="周四", [5]="周五", [6]="周六" }
local EN_WEEKS = { [0]="Sunday", [1]="Monday", [2]="Tuesday", [3]="Wednesday", [4]="Thursday", [5]="Friday", [6]="Saturday" }
local EN_WEEK_ABBRS = { [0]="Sun", [1]="Mon", [2]="Tue", [3]="Wed", [4]="Thu", [5]="Fri", [6]="Sat" }

local function has_dynamic_pattern(str)
  if not str or str == "" then return false end
  return (str:sub(1, 1) == "#") or (str:find("%$%([%w_%+%-%s]+%)") ~= nil)
end

local function build_vars(t)
  local date_tab = os.date("*t", t)
  local y = date_tab.year
  local m = date_tab.month
  local d = date_tab.day
  local w = date_tab.wday - 1
  local H = date_tab.hour
  local M_min = date_tab.min
  local S = date_tab.sec

  local H12 = H % 12
  if H12 == 0 then H12 = 12 end

  local y_str = string.format("%04d", y)
  local y_yy_str = string.format("%02d", y % 100)
  local m_str = tostring(m)
  local m_mm_str = string.format("%02d", m)
  local d_str = tostring(d)
  local d_dd_str = string.format("%02d", d)
  local H_str = tostring(H)
  local HH_str = string.format("%02d", H)
  local hh_str = string.format("%02d", H12)
  local h_str = tostring(H12)
  local min_str = tostring(M_min)
  local mm_str = string.format("%02d", M_min)
  local sec_str = tostring(S)
  local ss_str = string.format("%02d", S)

  local y_cn = y_str:gsub("%d", CN_DIGITS)
  local y_yy_cn = y_yy_str:gsub("%d", CN_DIGITS)
  local m_cn = CN_MONTHS[m] or m_str
  local d_cn = CN_DAYS[d] or d_str

  return {
    -- 年份
    year = y_str, yyyy = y_str, YYYY = y_str,
    year_yy = y_yy_str, yy = y_yy_str, YY = y_yy_str,
    year_cn = y_cn, year_yy_cn = y_yy_cn,

    -- 月份
    month = m_str, m = m_str, M = m_str,
    month_mm = m_mm_str, mm = m_mm_str, MM = m_mm_str,
    month_cn = m_cn,

    -- 日期
    day = d_str, d = d_str, D = d_str,
    day_dd = d_dd_str, dd = d_dd_str, DD = d_dd_str,
    day_cn = d_cn,

    -- 星期
    week = CN_WEEKS[w] or "",
    week_cn = CN_WEEKS[w] or "",
    weekday_cn = CN_WEEKDAYS[w] or "",
    week_en = EN_WEEKS[w] or "",
    week_abbr = EN_WEEK_ABBRS[w] or "",

    -- 时间
    hour = H_str, h = h_str, H = H_str,
    fullhour = HH_str, hh = hh_str, HH = HH_str,
    halfhour = hh_str, hour12 = h_str,
    minute = mm_str, min = mm_str, minute_m = min_str,
    second = ss_str, sec = ss_str, second_s = sec_str,
    s = sec_str, ss = ss_str,
    ampm = (H < 12) and "AM" or "PM",
    ampm_cn = (H < 12) and "上午" or "下午",

    -- 快捷预设组合
    date = string.format("%s-%s-%s", y_str, m_mm_str, d_dd_str),
    time = string.format("%s:%s:%s", HH_str, mm_str, ss_str),
    timestamp = tostring(t),
    _raw_ymd = string.format("%s%s%s", y_str, m_mm_str, d_dd_str),
  }
end

local function expand_dynamic_text(text, now)
  if not text or text == "" then return "" end
  local is_hash_prefixed = (text:sub(1, 1) == "#")
  local has_var = (text:find("%$%([%w_%+%-%s]+%)") ~= nil)

  if not is_hash_prefixed and not has_var then
    return text
  end

  local content = text
  if is_hash_prefixed then
    content = content:sub(2)
  end

  now = now or os.time()
  local base_date_tab = os.date("*t", now)
  local base_vars = build_vars(now)

  local function resolve_var_expr(expr)
    local raw_k, op, offset_num = expr:match("^%s*([%w_]+)%s*([%+%-]?)%s*(%d*)%s*$")
    if not raw_k then return "$(" .. expr .. ")" end

    local off = 0
    if op and op ~= "" and offset_num and offset_num ~= "" then
      off = tonumber(offset_num) or 0
      if op == "-" then off = -off end
    end

    local lk = raw_k:lower()
    local target_vars = base_vars

    if off ~= 0 then
      local off_y, off_m, off_d = 0, 0, 0
      local off_H, off_min, off_sec = 0, 0, 0

      if lk:find("year") or lk:find("yyyy") or lk == "yy" then
        off_y = off
      elseif lk:find("month") or lk == "m" or lk == "mm" then
        off_m = off
      elseif lk:find("day") or lk == "d" or lk == "dd" or lk:find("date") or lk:find("week") then
        off_d = off
      elseif lk:find("hour") or lk == "h" or lk == "hh" then
        off_H = off
      elseif lk:find("minute") or lk == "min" then
        off_min = off
      elseif lk:find("second") or lk == "sec" or lk == "s" or lk == "ss" then
        off_sec = off
      end

      local target_t = os.time({
        year = base_date_tab.year + off_y,
        month = base_date_tab.month + off_m,
        day = base_date_tab.day + off_d,
        hour = base_date_tab.hour + off_H,
        min = base_date_tab.min + off_min,
        sec = base_date_tab.sec + off_sec,
      })
      target_vars = build_vars(target_t)
    end

    if lk == "year_ln" or lk == "animal" or lk == "shengxiao" or lk == "month_ln" or lk == "day_ln" then
      if not target_vars._lunar_loaded then
        target_vars._lunar_loaded = true
        pcall(function()
          local clc = require("chineseLunarCalendar_translator")
          local fn = (type(clc) == "table" and clc.solar2LunarByTime)
            or (type(clc) == "function" and clc.solar2LunarByTime)
          if fn then
            local linfo = fn(target_vars._raw_ymd)
            if linfo then
              target_vars.year_ln = (linfo.year_ganZhi or "") .. "年"
              target_vars.animal = linfo.year_shengXiao or ""
              target_vars.shengxiao = linfo.year_shengXiao or ""
              target_vars.month_ln = (linfo.month_shuXu or "") .. "月"
              target_vars.day_ln = linfo.day_shuXu or ""
            end
          end
        end)
      end
    end

    return target_vars[raw_k] or target_vars[lk] or ("$(" .. expr .. ")")
  end

  local res = content:gsub("%$%(([%w_%+%-%s]+)%)", resolve_var_expr)

  -- 若以 # 开头且未包含 $()，对大写标准代号做容错替换
  if is_hash_prefixed and (not has_var) then
    res = res:gsub("YYYY", base_vars.year)
             :gsub("YY", base_vars.year_yy)
             :gsub("MM", base_vars.month_mm)
             :gsub("DD", base_vars.day_dd)
             :gsub("HH", base_vars.fullhour)
  end

  return res
end

--------------------------------------------------------------------------------
-- 4. 内存文本解析
--------------------------------------------------------------------------------
local function parse_content(content)
  local raw_map = {}
  local raw_map_exact = {}
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
        local exact_code = raw_code:match("^%s*(.-)%s*$")
        local code = exact_code:lower()

        local rest = clean_line:sub(eq_e + 1)
        local comma_s, comma_e = find_first_of(rest, { ",", "，" })
        local pos = 1
        local candidate_part = rest
        if comma_s then
          local raw_pos = rest:sub(1, comma_s - 1)
          local pos_str = raw_pos:match("^%s*(.-)%s*$")
          local parsed_pos = tonumber(pos_str)
          if parsed_pos and parsed_pos > 0 and math.floor(parsed_pos) == parsed_pos then
            pos = parsed_pos
            candidate_part = rest:sub(comma_e + 1)
          end
        end

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
              local has_upper = exact_code:find("%u") ~= nil
              if has_upper then
                -- 包含大写字母的词条（如 Ags, Bgs, Cgs, Upj）：严格仅记录精确大写映射
                local exact_entry = raw_map_exact[exact_code]
                if not exact_entry then
                  exact_entry = { slots = {}, commits = {}, comments = {}, details = {} }
                  raw_map_exact[exact_code] = exact_entry
                end
                exact_entry.slots[pos] = display_text
                exact_entry.commits[pos] = commit_text
                if comment and comment ~= "" then exact_entry.comments[pos] = comment end
                if detail and detail ~= "" then exact_entry.details[pos] = detail end
              else
                -- 纯小写词条（如 wsm, bj）：仅记录纯小写映射
                local entry = raw_map[code]
                if not entry then
                  entry = { slots = {}, commits = {}, comments = {}, details = {} }
                  raw_map[code] = entry
                end
                entry.slots[pos] = display_text
                entry.commits[pos] = commit_text
                if comment and comment ~= "" then entry.comments[pos] = comment else entry.comments[pos] = nil end
                if detail and detail ~= "" then entry.details[pos] = detail else entry.details[pos] = nil end
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

  local function build_slot_structure(source_map)
    local target = {}
    local entries = 0
    local codes = 0
    for c, raw_entry in pairs(source_map) do
      local texts = {}
      local commit_by_text = {}
      local max_pos = 0
      local count = 0
      local has_custom_commits = false
      local has_dynamic = false
      local detail_by_text = {}

      for p, txt in pairs(raw_entry.slots) do
        texts[txt] = true
        local c_txt = raw_entry.commits[p] or txt
        commit_by_text[txt] = c_txt
        if c_txt ~= txt or has_dynamic_pattern(c_txt) or has_dynamic_pattern(txt) then
          has_custom_commits = true
        end
        if has_dynamic_pattern(txt) or has_dynamic_pattern(c_txt)
           or (raw_entry.comments and has_dynamic_pattern(raw_entry.comments[p]))
           or (raw_entry.details and has_dynamic_pattern(raw_entry.details[p])) then
          has_dynamic = true
        end
        local detail = raw_entry.details[p]
        if detail and detail ~= "" then
          detail_by_text[txt] = detail
        end
        if p > max_pos then max_pos = p end
        count = count + 1
        entries = entries + 1
      end

      target[c] = {
        slots = raw_entry.slots,
        commits = raw_entry.commits,
        comments = raw_entry.comments,
        details = raw_entry.details,
        texts = texts,
        commit_by_text = commit_by_text,
        detail_by_text = detail_by_text,
        has_custom_commits = has_custom_commits,
        has_dynamic = has_dynamic,
        max_pos = max_pos,
        count = count,
      }
      codes = codes + 1
    end
    return target, entries, codes
  end

  local slots, total_entries, total_codes = build_slot_structure(raw_map)
  local slots_exact = build_slot_structure(raw_map_exact)

  return slots, total_entries, total_codes, slots_exact
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

  local new_slots, entries, codes, new_slots_exact = parse_content(content)
  if not new_slots or entries == 0 then
    if _G.log and _G.log.warning then
      _G.log.warning("[hot_slot] Parse yielded 0 entries, keeping old index")
    end
    return false
  end

  -- 更新指定文件缓存
  cache.slots = new_slots
  cache.slots_exact = new_slots_exact or {}
  cache.last_content = content
  cache.entry_count = entries
  cache.code_count = codes
  cache.loaded_once = true
  cache.last_check_time = os.time()

  -- 同步更新全局兼容字段
  M.slots = new_slots
  M.slots_exact = new_slots_exact or {}
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

M.expand_dynamic_text = expand_dynamic_text
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

  -- 提取当前 segment 输入编码
  local raw_input = context.input or ""
  if segment.start < 0 or segment._end > #raw_input or segment.start >= segment._end then
    for cand in input:iter() do yield(cand) end
    return
  end

  local raw_code = raw_input:sub(segment.start + 1, segment._end)
  local exact_slots = cache.slots_exact or M.slots_exact or {}
  local has_upper_input = (raw_input:find("%u") ~= nil) or (raw_code:find("%u") ~= nil)
  local slot_entry = nil

  if has_upper_input then
    -- 输入包含大写字母（支持大写字母+拼音，如 Ags, Bgs, Cgs, Upj）
    -- 仅允许精确匹配已定义的大写词条；未精确匹配大写词条时，零额外开销放行，绝不降级匹配小写普通词
    slot_entry = exact_slots[raw_code] or exact_slots[raw_input]
    if not slot_entry then
      for cand in input:iter() do yield(cand) end
      return
    end
  else
    -- 纯小写输入：仅匹配普通双拼小写固定词
    local code = raw_code:lower()
    slot_entry = cache.slots[code] or M.slots[code]
    if not slot_entry then
      for cand in input:iter() do yield(cand) end
      return
    end
  end

  local tab_mode = (context.get_property and context:get_property("tab_mode")) or ""

  -- 特殊模式与人名模式隔离：
  -- 默认仅作用于普通中文输入段落（abc）；
  -- 拆字模式（radical_lookup）下，若输入命中了手心精确大写词条（如 Upj 命中 Upj），允许放行出词！
  local is_radical_hit = (segment:has_tag("radical_lookup") or tab_mode == "u" or raw_input:sub(1, 1) == "U") and slot_entry and exact_slots[raw_input]
  if not segment:has_tag("abc") and not is_radical_hit then
    for cand in input:iter() do yield(cand) end
    return
  end

  for tag in pairs(EXCLUDED_TAGS) do
    if segment:has_tag(tag) then
      if not (tag == "radical_lookup" and is_radical_hit) then
        for cand in input:iter() do yield(cand) end
        return
      end
    end
  end

  if context:get_option("name_mode") then
    for cand in input:iter() do yield(cand) end
    return
  end

  if tab_mode ~= "" and not (tab_mode == "u" and is_radical_hit) then
    for cand in input:iter() do yield(cand) end
    return
  end

  -- 光标处于长句中间且处于单字及辅码音节（<=4码）时（用户逐字确认意图），抑制非单字固定词（如梁冰、曹操、手机号宏）
  local is_in_sentence_nav = context.caret_pos and (context.caret_pos < #raw_input) and ((segment._end - segment.start) <= 4)
  if is_in_sentence_nav then
    local has_single_char = false
    for _, text in pairs(slot_entry.slots) do
      local eval_t = expand_dynamic_text(text)
      local char_cnt = 0
      for _ in utf8.codes(eval_t) do char_cnt = char_cnt + 1 end
      if char_cnt == 1 then
        has_single_char = true
        break
      end
    end
    if not has_single_char then
      for cand in input:iter() do yield(cand) end
      return
    end
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

  local active_dynamic_texts = {}
  if slot_entry.has_dynamic then
    for _, raw_t in pairs(slot_entry.slots) do
      active_dynamic_texts[expand_dynamic_text(raw_t)] = true
    end
  end

  -- 原始候选流拉取器（自动过滤与固定词条内容相同的项）
  local function get_next_cand()
    while true do
      local cand = next_raw_cand()
      if not cand then return nil end
      if not (deduplicate and (slot_entry.texts[cand.text] or active_dynamic_texts[cand.text])) then
        return cand
      end
    end
  end

  local pos = 0
  local max_pos = slot_entry.max_pos
  local unyielded_slots_count = slot_entry.count
  local output_idx = 0

  local function yield_slot_candidate(p, raw_text)
    local raw_commit = (slot_entry.commits and slot_entry.commits[p]) or raw_text
    local raw_comment = (slot_entry.comments and slot_entry.comments[p]) or default_comment
    local raw_detail = slot_entry.details and slot_entry.details[p] or ""

    local text = expand_dynamic_text(raw_text)
    local slot_commit = expand_dynamic_text(raw_commit)
    local slot_comment = expand_dynamic_text(raw_comment)
    local slot_detail = expand_dynamic_text(raw_detail)

    if slot_commit ~= text then
      cache.active_commits[output_idx] = slot_commit
      M.active_commits[output_idx] = slot_commit
    end
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
      local eval_slot_text = expand_dynamic_text(slot_text)
      local skip_multi = is_in_sentence_nav and (utf8.len(eval_slot_text) or 0) > 1
      if not skip_multi then
        yield_slot_candidate(pos, slot_text)
      end
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
  local raw_code = raw_input:sub(seg.start + 1, seg._end)
  local cache = (env.filepath and get_cache(env.filepath)) or env.cache or get_cache(M.active_filepath)
  local exact_slots = cache.slots_exact or M.slots_exact or {}
  local has_upper_input = (raw_input:find("%u") ~= nil) or (raw_code:find("%u") ~= nil)
  local slot_entry = nil
  if has_upper_input then
    slot_entry = exact_slots[raw_code] or exact_slots[raw_input]
  else
    local code = raw_code:lower()
    slot_entry = cache.slots[code] or M.slots[code]
  end
  if not slot_entry then
    clear_owned_detail(context)
    return
  end

  local cand = context.get_selected_candidate and context:get_selected_candidate() or nil
  if not cand and seg.get_selected_candidate then cand = seg:get_selected_candidate() end
  local sel_idx = seg.selected_index or 0
  local active_details = cache.active_details or M.active_details or {}
  local detail = active_details[sel_idx]
    or (cand and slot_entry.detail_by_text and expand_dynamic_text(slot_entry.detail_by_text[cand.text]))
    or (slot_entry.details and slot_entry.details[sel_idx + 1] and expand_dynamic_text(slot_entry.details[sel_idx + 1]))
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
    local raw_code = raw_input:sub(seg.start + 1, seg._end)
    local cache = (env.filepath and get_cache(env.filepath)) or env.cache or get_cache(M.active_filepath)
    local exact_slots = cache.slots_exact or M.slots_exact or {}
    local has_upper_input = (raw_input:find("%u") ~= nil) or (raw_code:find("%u") ~= nil)
    local slot_entry = nil
    if has_upper_input then
      slot_entry = exact_slots[raw_code] or exact_slots[raw_input]
    else
      local code = raw_code:lower()
      slot_entry = cache.slots[code] or M.slots[code]
    end
    if not slot_entry or not slot_entry.has_custom_commits then return end

    local sel_idx = seg.selected_index or 0
    local custom_commit = (cache.active_commits and cache.active_commits[sel_idx])
      or (M.active_commits and M.active_commits[sel_idx])
      or (cand and slot_entry.commit_by_text and slot_entry.commit_by_text[cand.text] and expand_dynamic_text(slot_entry.commit_by_text[cand.text]))
      or (slot_entry.commits and slot_entry.commits[sel_idx + 1] and expand_dynamic_text(slot_entry.commits[sel_idx + 1]))

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
  if not seg then return kNoop end

  local raw_input = context.input or ""
  if seg.start < 0 or seg._end > #raw_input or seg.start >= seg._end then return kNoop end
  local raw_code = raw_input:sub(seg.start + 1, seg._end)
  local cache = (env.filepath and get_cache(env.filepath)) or env.cache or get_cache(M.active_filepath)
  local exact_slots = cache.slots_exact or M.slots_exact or {}
  local has_upper_input = (raw_input:find("%u") ~= nil) or (raw_code:find("%u") ~= nil)
  local slot_entry = nil

  if has_upper_input then
    slot_entry = exact_slots[raw_code] or exact_slots[raw_input]
    if not slot_entry then return kNoop end
  else
    local code = raw_code:lower()
    slot_entry = cache.slots[code] or M.slots[code]
    if not slot_entry then return kNoop end
  end

  local tab_mode = (context.get_property and context:get_property("tab_mode")) or ""
  local is_radical_hit = (seg:has_tag("radical_lookup") or tab_mode == "u" or raw_input:sub(1, 1) == "U") and slot_entry and exact_slots[raw_input]
  if not seg:has_tag("abc") and not is_radical_hit then return kNoop end

  for tag in pairs(EXCLUDED_TAGS) do
    if seg:has_tag(tag) then
      if not (tag == "radical_lookup" and is_radical_hit) then return kNoop end
    end
  end

  if context:get_option("name_mode") then return kNoop end
  if tab_mode ~= "" and not (tab_mode == "u" and is_radical_hit) then return kNoop end

  if not slot_entry.has_custom_commits then
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
    local raw_c = slot_entry.commit_by_text and slot_entry.commit_by_text[target_cand.text]
    if raw_c then
      target_commit = expand_dynamic_text(raw_c)
    end
  end
  if not target_commit then
    local raw_c = slot_entry.commits and slot_entry.commits[target_index + 1]
    if raw_c then
      target_commit = expand_dynamic_text(raw_c)
    end
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
