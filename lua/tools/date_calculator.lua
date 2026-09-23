local set_mode_prompt = require("mode_prompt")

--[[
  date_calculator.lua
  Rime 日期输入与日期计算核心模块
  功能：
    - R: 默认显示今天日期（按5个指定顺位）
    - Rrq, Rsj, Rdt, Rxq, Rnl, Rgx: 日期、时间、日期时间、星期、农历、更新法定节假日
    - RYYYYMMDD: 指定日期转换（合法性严格校验）
    - RYYYYMMDD+N / -N / R+N / -N: 自然日加减
    - RYYYYMMDD+Ny / -Ny / R+Ny / -Ny: 月份加减（月，月末自动对齐）
    - RYYYYMMDD+Nn / -Nn / R+Nn / -Nn: 年份加减（年，闰年2月29日对齐）
    - RYYYYMMDD-YYYYMMDD: 日期间隔（中间用减号，8位数字识别为日期）
    - RYYYYMMDD+Ng / -Ng / R+Ng / -Ng: 中国工作日加减（遇节假日/调休准确计算，缺数据提示）
    - RYYYYMMDD-YYYYMMDDg: 两个日期之间的工作日数量统计
--]]

local holidays = nil
pcall(function()
    holidays = require("holidays")
end)

local holiday_update = nil
pcall(function()
    holiday_update = require("holiday_update")
end)

-- ----------------------------------------------------
-- 纯 Gregorian 历法基础算法
-- ----------------------------------------------------

local function is_leap_year(y)
    return (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
end

local function days_in_month(y, m)
    local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if m == 2 and is_leap_year(y) then return 29 end
    return days[m] or 30
end

local function is_valid_date(y, m, d)
    if not y or not m or not d then return false end
    if y < 1 or y > 9999 then return false end
    if m < 1 or m > 12 then return false end
    if d < 1 or d > days_in_month(y, m) then return false end
    return true
end

-- 公历绝对天数（以公元 1年1月1日为第 1 天）
local function date_to_days(y, m, d)
    local y_prev = y - 1
    local total = y_prev * 365 + math.floor(y_prev / 4) - math.floor(y_prev / 100) + math.floor(y_prev / 400)
    for i = 1, m - 1 do
        total = total + days_in_month(y, i)
    end
    return total + d
end

local function days_to_date(n)
    local y = 1
    local era = math.floor((n - 1) / 146097)
    local rem = n - era * 146097
    y = y + era * 400

    local c100 = math.min(math.floor((rem - 1) / 36524), 3)
    rem = rem - c100 * 36524
    y = y + c100 * 100

    local c4 = math.min(math.floor((rem - 1) / 1461), 24)
    rem = rem - c4 * 1461
    y = y + c4 * 4

    local c1 = math.min(math.floor((rem - 1) / 365), 3)
    rem = rem - c1 * 365
    y = y + c1

    local m = 1
    while true do
        local dim = days_in_month(y, m)
        if rem <= dim then break end
        rem = rem - dim
        m = m + 1
    end
    local d = rem
    return y, m, d
end

local function weekday(y, m, d)
    local days = date_to_days(y, m, d)
    -- 公元 1年1月1日是星期一
    return ((days - 1) % 7) + 1
end

local function add_days(y, m, d, n)
    local total = date_to_days(y, m, d) + n
    return days_to_date(total)
end

-- 月份加减（月末截断对齐规则）
local function add_months(y, m, d, n)
    local total_m = y * 12 + (m - 1) + n
    local ty = math.floor(total_m / 12)
    local tm = (total_m % 12) + 1
    local max_d = days_in_month(ty, tm)
    local td = math.min(d, max_d)
    return ty, tm, td
end

-- 年份加减（闰年2月29日对齐规则）
local function add_years(y, m, d, n)
    local ty = y + n
    local tm = m
    local max_d = days_in_month(ty, tm)
    local td = math.min(d, max_d)
    return ty, tm, td
end

-- ----------------------------------------------------
-- 工作日与节假日算法
-- ----------------------------------------------------

local function get_holidays()
    if package.loaded["holidays"] then
        return package.loaded["holidays"]
    end
    if not holidays then
        pcall(function()
            holidays = require("holidays")
        end)
    end
    return holidays
end

local function has_holiday_data(y)
    local h = get_holidays()
    if not h or not h.years then return false end
    return h.years[y] == true
end

local function is_workday(y, m, d)
    local h = get_holidays()
    local key = string.format("%04d-%02d-%02d", y, m, d)
    if h and h.days and h.days[key] ~= nil then
        return h.days[key]
    end
    local w = weekday(y, m, d)
    return (w >= 1 and w <= 5)
end

local function is_weekend(y, m, d)
    local w = weekday(y, m, d)
    return (w == 6 or w == 7)
end

-- 计算工作日加减：返回 (ty, tm, td, missing_years)
local function add_workdays(y, m, d, n)
    local step = (n >= 0) and 1 or -1
    local remain = math.abs(n)
    local cy, cm, cd = y, m, d
    local missing_map = {}

    if not has_holiday_data(cy) then
        missing_map[cy] = true
    end

    while remain > 0 do
        cy, cm, cd = add_days(cy, cm, cd, step)
        if not has_holiday_data(cy) then
            missing_map[cy] = true
        end
        if is_workday(cy, cm, cd) then
            remain = remain - 1
        end
    end

    local missing_list = {}
    for my, _ in pairs(missing_map) do
        table.insert(missing_list, my)
    end
    table.sort(missing_list)

    return cy, cm, cd, missing_list
end

-- 仅按周一至周五估算工作日加减
local function add_workdays_estimate(y, m, d, n)
    local step = (n >= 0) and 1 or -1
    local remain = math.abs(n)
    local cy, cm, cd = y, m, d
    while remain > 0 do
        cy, cm, cd = add_days(cy, cm, cd, step)
        local w = weekday(cy, cm, cd)
        if w >= 1 and w <= 5 then
            remain = remain - 1
        end
    end
    return cy, cm, cd
end

-- 两个日期之间的工作日数量统计
-- 返回：workday_exclusive (start, end], workday_inclusive [start, end], natural_days, missing_list
local function workdays_between(y1, m1, d1, y2, m2, d2)
    local ord1 = date_to_days(y1, m1, d1)
    local ord2 = date_to_days(y2, m2, d2)
    local reversed = false
    if ord1 > ord2 then
        ord1, ord2 = ord2, ord1
        reversed = true
    end

    local natural_days = ord2 - ord1
    local count_exclusive = 0
    local count_inclusive = 0
    local missing_map = {}

    for ord = ord1, ord2 do
        local cy, cm, cd = days_to_date(ord)
        if not has_holiday_data(cy) then
            missing_map[cy] = true
        end
        if is_workday(cy, cm, cd) then
            count_inclusive = count_inclusive + 1
            if ord > ord1 then
                count_exclusive = count_exclusive + 1
            end
        end
    end

    local missing_list = {}
    for my, _ in pairs(missing_map) do
        table.insert(missing_list, my)
    end
    table.sort(missing_list)

    return count_exclusive, count_inclusive, natural_days, missing_list, reversed
end

-- 法定休假日顺延函数
-- 如果 (y, m, d) 本身为工作日，无需顺延，返回 y, m, d, 0, nil
-- 如果为法定休假日，顺延到下一个工作日；若涉及年份缺少节假日数据，返回 nil, nil, nil, nil, missing_year
local function delay_to_next_workday(y, m, d)
    if not has_holiday_data(y) then
        return nil, nil, nil, nil, y
    end

    if is_workday(y, m, d) then
        return y, m, d, 0, nil
    end

    local cy, cm, cd = y, m, d
    while true do
        cy, cm, cd = add_days(cy, cm, cd, 1)
        if not has_holiday_data(cy) then
            return nil, nil, nil, nil, cy
        end
        if is_workday(cy, cm, cd) then
            local delay_days = date_to_days(cy, cm, cd) - date_to_days(y, m, d)
            return cy, cm, cd, delay_days, nil
        end
    end
end

-- ----------------------------------------------------
-- 格式化辅助函数
-- ----------------------------------------------------

local ZH_DIGITS = { [0] = "〇", "一", "二", "三", "四", "五", "六", "七", "八", "九" }
local ZH_MONTHS = { "一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二" }
local ZH_DAYS = {
    "一", "二", "三", "四", "五", "六", "七", "八", "九", "十",
    "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
    "二十一", "二十二", "二十三", "二十四", "二十五", "二十六", "二十七", "二十八", "二十九", "三十", "三十一"
}
local WEEKDAY_NAMES = { "一", "二", "三", "四", "五", "六", "日" }

local function format_chinese_date(y, m, d)
    local y_str = tostring(y)
    local zh_y = ""
    for i = 1, #y_str do
        local digit = tonumber(y_str:sub(i, i))
        zh_y = zh_y .. (ZH_DIGITS[digit] or "")
    end
    local zh_m = ZH_MONTHS[m] or tostring(m)
    local zh_d = ZH_DAYS[d] or tostring(d)
    return zh_y .. "年" .. zh_m .. "月" .. zh_d .. "日"
end

-- 获取农历文字（优先调用已有模块）
local function get_lunar_text(y, m, d)
    if _G.Date2LunarDate then
        local ok, res = pcall(_G.Date2LunarDate, string.format("%04d%02d%02d", y, m, d))
        if ok and res and res ~= "" then return res end
    end
    return nil
end

-- 按照用户指定的 5 个固定顺位生成候选（严格对应 abcde 选词）：
-- a. 20260919_
-- b. 2026年9月19日
-- c. 二〇二六年九月十九日
-- d. 2026.09.19
-- e. 2026-09-19
local function yield_date_candidates(yield_fn, seg, y, m, d, comment_suffix)
    local tag = "date_calc"
    local s_start, s_end = seg.start, seg._end
    local c_suffix = comment_suffix and (" " .. comment_suffix) or ""

    local f1 = string.format("%04d%02d%02d_", y, m, d)
    local f2 = string.format("%d年%d月%d日", y, m, d)
    local f3 = format_chinese_date(y, m, d)
    local f4 = string.format("%04d.%02d.%02d", y, m, d)
    local f5 = string.format("%04d-%02d-%02d", y, m, d)

    local cands = {
        { f2, "〔日期〕" .. c_suffix },
        { f1, "〔日期〕" .. c_suffix },
        { f3, "〔中文日期〕" .. c_suffix },
        { f4, "〔日期〕" .. c_suffix },
        { f5, "〔ISO日期〕" .. c_suffix },
    }

    for _, c in ipairs(cands) do
        local cand = Candidate(tag, s_start, s_end, c[1], c[2])
        cand.quality = 1000
        yield_fn(cand)
    end
end

local function format_chinese_month_day(m, d)
    local zh_m = ZH_MONTHS[m] or tostring(m)
    local zh_d = ZH_DAYS[d] or tostring(d)
    return zh_m .. "月" .. zh_d .. "日"
end

-- 四位数月日专属候选排布（以 0101 为例）：
-- 1. 2026年1月1日
-- 2. 20260101_
-- 3. 二〇二六年一月一日
-- 4. 1月1日
-- 5. 一月一日
local function yield_four_digit_candidates(yield_fn, seg, y, m, d, comment_suffix)
    local tag = "date_calc"
    local s_start, s_end = seg.start, seg._end
    local c_suffix = comment_suffix and (" " .. comment_suffix) or ""

    local f1 = string.format("%d年%d月%d日", y, m, d)
    local f2 = string.format("%04d%02d%02d_", y, m, d)
    local f3 = format_chinese_date(y, m, d)
    local f4 = string.format("%d月%d日", m, d)
    local f5 = format_chinese_month_day(m, d)

    local cands = {
        { f1, "〔日期〕" .. c_suffix },
        { f2, "〔日期〕" .. c_suffix },
        { f3, "〔中文日期〕" .. c_suffix },
        { f4, "〔月日〕" .. c_suffix },
        { f5, "〔中文月日〕" .. c_suffix },
    }

    for _, c in ipairs(cands) do
        local cand = Candidate(tag, s_start, s_end, c[1], c[2])
        cand.quality = 1000
        yield_fn(cand)
    end
end

-- 解析日期标记，支持：
-- 1. 8位数字 YYYYMMDD
-- 2. 4位数字 MMDD（前两位 <= 12 且合法）
-- 3. 年初：YYYYni / YYYYnc / ni / nc
-- 4. 年末：YYYYnm / nm
-- 5. 月初：YYYYMMyi / YYYYMMyc / MMyi / MMyc / yi / yc
-- 6. 月末：YYYYMMym / MMym / ym
local function parse_date_token(token, cur_y, cur_m, cur_d)
    if not token or token == "" then return nil, nil, nil, nil, nil end

    -- 0. 今年(jn)、去年(qn)、明年(mn)指代年份或具体日期
    local year_alias = {
        jn = cur_y,
        qn = cur_y - 1,
        mn = cur_y + 1,
    }
    local y_pref = token:sub(1, 2)
    if year_alias[y_pref] then
        local target_y = year_alias[y_pref]
        local rest = token:sub(3)
        if rest == "" then
            -- 单独 jn / qn / mn：指向该年份的今天（如 2月29日在平年对齐为 2月28日）
            local td = math.min(cur_d, days_in_month(target_y, cur_m))
            return target_y, cur_m, td, "keyword", nil
        elseif rest == "ni" or rest == "nc" then
            -- 年初：如 qnni, qnnc, mnni, jnni
            return target_y, 1, 1, "keyword", nil
        elseif rest == "nm" then
            -- 年末：如 qnnm, mnnm, jnnm
            return target_y, 12, 31, "keyword", nil
        elseif #rest == 4 and rest:match("^%d%d%d%d$") then
            -- 4位月日：如 qn0101, mn0501, jn1001
            local rm = tonumber(rest:sub(1, 2))
            local rd = tonumber(rest:sub(3, 4))
            if rm >= 1 and rm <= 12 and is_valid_date(target_y, rm, rd) then
                return target_y, rm, rd, "4digit", nil
            else
                return nil, nil, nil, nil, string.format("日期无效：%04d-%02d-%02d", target_y, rm, rd)
            end
        else
            -- 月初：如 qn05yi, mn5yc, jnyi
            local m_yi = rest:match("^([01]?%d)y[ic]$")
            if m_yi then
                local m = tonumber(m_yi)
                if m >= 1 and m <= 12 then
                    return target_y, m, 1, "keyword", nil
                end
            elseif rest == "yi" or rest == "yc" then
                return target_y, cur_m, 1, "keyword", nil
            end

            -- 月末：如 qn02ym, mn12ym, jnym
            local m_ym = rest:match("^([01]?%d)ym$")
            if m_ym then
                local m = tonumber(m_ym)
                if m >= 1 and m <= 12 then
                    return target_y, m, days_in_month(target_y, m), "keyword", nil
                end
            elseif rest == "ym" then
                return target_y, cur_m, days_in_month(target_y, cur_m), "keyword", nil
            end
        end
    end

    -- 1. 8位完整日期
    local y8, m8, d8 = token:match("^(%d%d%d%d)(%d%d)(%d%d)$")
    if y8 then
        local y, m, d = tonumber(y8), tonumber(m8), tonumber(d8)
        if is_valid_date(y, m, d) then
            return y, m, d, "8digit", nil
        else
            return nil, nil, nil, nil, string.format("日期无效：%04d-%02d-%02d", y, m, d)
        end
    end

    -- 2. 4位数字：小于等于12时指向当前年份月日
    local m4, d4 = token:match("^(%d%d)(%d%d)$")
    if m4 then
        local m, d = tonumber(m4), tonumber(d4)
        if m >= 1 and m <= 12 then
            if is_valid_date(cur_y, m, d) then
                return cur_y, m, d, "4digit", nil
            else
                return nil, nil, nil, nil, string.format("日期无效：%04d-%02d-%02d", cur_y, m, d)
            end
        else
            -- 前两位 > 12，不作为有效月日识别
            return nil, nil, nil, nil, nil
        end
    end

    -- 3. 年初：双拼 ni，全拼 nc
    local y_ni = token:match("^(%d%d%d%d)n[ic]$")
    if y_ni then
        local y = tonumber(y_ni)
        if y >= 1 and y <= 9999 then
            return y, 1, 1, "keyword", nil
        end
    elseif token == "ni" or token == "nc" then
        return cur_y, 1, 1, "keyword", nil
    end

    -- 4. 年末：nm
    local y_nm = token:match("^(%d%d%d%d)nm$")
    if y_nm then
        local y = tonumber(y_nm)
        if y >= 1 and y <= 9999 then
            return y, 12, 31, "keyword", nil
        end
    elseif token == "nm" then
        return cur_y, 12, 31, "keyword", nil
    end

    -- 5. 月初：双拼 yi，全拼 yc
    local y_yi, m_yi = token:match("^(%d%d%d%d)(%d%d)y[ic]$")
    if y_yi then
        local y, m = tonumber(y_yi), tonumber(m_yi)
        if y >= 1 and y <= 9999 and m >= 1 and m <= 12 then
            return y, m, 1, "keyword", nil
        end
    end
    local m_yi2 = token:match("^([01]?%d)y[ic]$")
    if m_yi2 then
        local m = tonumber(m_yi2)
        if m >= 1 and m <= 12 then
            return cur_y, m, 1, "keyword", nil
        end
    end
    if token == "yi" or token == "yc" then
        return cur_y, cur_m, 1, "keyword", nil
    end

    -- 6. 月末：ym
    local y_ym, m_ym = token:match("^(%d%d%d%d)(%d%d)ym$")
    if y_ym then
        local y, m = tonumber(y_ym), tonumber(m_ym)
        if y >= 1 and y <= 9999 and m >= 1 and m <= 12 then
            return y, m, days_in_month(y, m), "keyword", nil
        end
    end
    local m_ym2 = token:match("^([01]?%d)ym$")
    if m_ym2 then
        local m = tonumber(m_ym2)
        if m >= 1 and m <= 12 then
            return cur_y, m, days_in_month(cur_y, m), "keyword", nil
        end
    end
    if token == "ym" then
        return cur_y, cur_m, days_in_month(cur_y, cur_m), "keyword", nil
    end

    return nil, nil, nil, nil, nil
end

-- ----------------------------------------------------
-- Translator 主入口
-- ----------------------------------------------------

local function translator(input, seg, env)
    -- 只处理以 R 开头的输入 (仅响应 r+Tab 或 rl+Tab 引导)
    if not input:match("^R") then
        return
    end

    local context = env.engine and env.engine.context
    local tab_mode = context and context:get_property("tab_mode") or ""
    if tab_mode ~= "r" and tab_mode ~= "rf" then
        return
    end

    -- 设置说明提示
    set_mode_prompt(env, seg, "〔日期及计算〕")

    -- 无论使用哪个日期指令，都先应用后台已经下载完成的数据，避免继续使用旧缓存
    if holiday_update and holiday_update.check_and_apply_tmp then
        pcall(holiday_update.check_and_apply_tmp)
    end

    local now = os.date("*t")
    local cur_y, cur_m, cur_d = now.year, now.month, now.day

    local is_delay_mode = false
    local body = input:sub(2)

    -- 检查前缀 F/f (RF 顺延模式)
    if body:match("^[Ff]") then
        is_delay_mode = true
        body = body:sub(2)
    end

    -- 1. 单个 R / RF：默认显示今天日期（按 5 个顺位）
    if body == "" or body == "rq" then
        if is_delay_mode then
            local sy, sm, sd, delay_days, err_y = delay_to_next_workday(cur_y, cur_m, cur_d)
            if err_y then
                yield(Candidate("date_calc", seg.start, seg._end, string.format("缺少%d年中国节假日数据，无法计算法定休假日顺延", err_y), "〔错误〕"))
                return
            end
            local comment = (delay_days > 0) and string.format("原%d月%d日休假，顺延%d天至工作日", cur_m, cur_d, delay_days) or "法定顺延：已是工作日"
            yield_date_candidates(yield, seg, sy, sm, sd, comment)
        else
            yield_date_candidates(yield, seg, cur_y, cur_m, cur_d, "今天")
        end
        return
    end

    -- 2. 手动更新指令：Rgx（检查并更新国务院法定节假日安排）
    if body == "gx" then
        if holiday_update and holiday_update.trigger_update then
            holiday_update.trigger_update(true)
        end
        local cand = Candidate("date_calc", seg.start, seg._end, "已请求检查法定节假日更新", "后台异步更新中，稍后生效")
        cand.quality = 1000
        yield(cand)
        return
    end

    -- 3. 快捷指令：Rsj, Rdt, Rxq, Rnl (在非顺延模式下响应)
    if not is_delay_mode then
        if body == "sj" then
            local t1 = string.format("%02d:%02d", now.hour, now.min)
            local t2 = string.format("%02d:%02d:%02d", now.hour, now.min, now.sec)
            local t3 = string.format("%d时%d分", now.hour, now.min)
            local t4 = string.format("%d时%d分%d秒", now.hour, now.min, now.sec)
            local list = {
                { t1, "〔时间〕" },
                { t2, "〔时间〕" },
                { t3, "〔时间〕" },
                { t4, "〔时间〕" },
            }
            for _, c in ipairs(list) do
                local cand = Candidate("date_calc", seg.start, seg._end, c[1], c[2])
                cand.quality = 1000
                yield(cand)
            end
            return
        end

        if body == "dt" then
            local dt1 = string.format("%04d-%02d-%02d %02d:%02d", cur_y, cur_m, cur_d, now.hour, now.min)
            local dt2 = string.format("%04d-%02d-%02d %02d:%02d:%02d", cur_y, cur_m, cur_d, now.hour, now.min, now.sec)
            local dt3 = string.format("%d年%d月%d日%d时%d分", cur_y, cur_m, cur_d, now.hour, now.min)
            local list = {
                { dt1, "〔日期时间〕" },
                { dt2, "〔日期时间〕" },
                { dt3, "〔日期时间〕" },
            }
            for _, c in ipairs(list) do
                local cand = Candidate("date_calc", seg.start, seg._end, c[1], c[2])
                cand.quality = 1000
                yield(cand)
            end
            return
        end

        if body == "xq" then
            local w = weekday(cur_y, cur_m, cur_d)
            local list = {
                { "星期" .. WEEKDAY_NAMES[w], "〔星期〕" },
                { "周" .. WEEKDAY_NAMES[w], "〔星期〕" },
                { WEEKDAY_NAMES[w], "〔星期〕" },
            }
            for _, c in ipairs(list) do
                local cand = Candidate("date_calc", seg.start, seg._end, c[1], c[2])
                cand.quality = 1000
                yield(cand)
            end
            return
        end

        if body == "nl" then
            local lunar = get_lunar_text(cur_y, cur_m, cur_d)
            if lunar then
                local cand = Candidate("date_calc", seg.start, seg._end, lunar, "〔当前农历〕")
                cand.quality = 1000
                yield(cand)
            end
            return
        end
    end

    -- 3. 日期间隔计算（减号两边为合法日期 Token）
    local is_interval = false
    local int_y1, int_m1, int_d1, int_y2, int_m2, int_d2, int_g

    -- 形式 1：以 '-' 开头（如 -0101, -nm, -20260918, -0101g 等，以今天为起点）
    local neg_rest, neg_g = body:match("^%-(.-)([g]?)$")
    if neg_rest and neg_rest ~= "" then
        local y2, m2, d2, ttype2 = parse_date_token(neg_rest, cur_y, cur_m, cur_d)
        if y2 then
            is_interval = true
            int_y1, int_m1, int_d1 = cur_y, cur_m, cur_d
            int_y2, int_m2, int_d2 = y2, m2, d2
            int_g = (neg_g == "g")
        end
    end

    -- 形式 2：两个 Token 由 '-' 分隔（如 0101-0201, ni-nm, 2024nm-2024ni, 20260901-20260918 等）
    if not is_interval then
        local t1, t2, g_part = body:match("^(.-)%-(.-)([g]?)$")
        if t1 and t1 ~= "" and t2 and t2 ~= "" then
            local y1, m1, d1, ttype1 = parse_date_token(t1, cur_y, cur_m, cur_d)
            local y2, m2, d2, ttype2 = parse_date_token(t2, cur_y, cur_m, cur_d)
            if y1 and y2 then
                is_interval = true
                int_y1, int_m1, int_d1 = y1, m1, d1
                int_y2, int_m2, int_d2 = y2, m2, d2
                int_g = (g_part == "g")
            end
        end
    end

    if is_interval then
        local y1, m1, d1 = int_y1, int_m1, int_d1
        local y2, m2, d2 = int_y2, int_m2, int_d2
        if int_g then
            -- 计算两个日期之间的工作日数量（显式指定 g 模式）
            local wk_ex, wk_in, nat_days, missing_list, reversed = workdays_between(y1, m1, d1, y2, m2, d2)
            if #missing_list > 0 then
                local tip = string.format("缺少%s年中国节假日数据，无法计算工作日", table.concat(missing_list, "/"))
                yield(Candidate("date_calc", seg.start, seg._end, tip, "〔错误〕"))
                yield(Candidate("date_calc", seg.start, seg._end, string.format("%d个自然日", nat_days), "自然日"))
                return
            end
            local comment_ex = "(起,止]工作日"
            local comment_in = "[起,止]工作日"
            yield(Candidate("date_calc", seg.start, seg._end, string.format("%d个工作日", wk_ex), comment_ex))
            yield(Candidate("date_calc", seg.start, seg._end, string.format("%d个工作日（含首尾）", wk_in), comment_in))
            yield(Candidate("date_calc", seg.start, seg._end, string.format("%d个自然日", nat_days), "自然日"))
            return
        else
            -- 计算自然日期间隔（第 3 候选项增加工作日计算，且超出节假日数据范围时严格报错）
            local ord1 = date_to_days(y1, m1, d1)
            local ord2 = date_to_days(y2, m2, d2)
            local diff = math.abs(ord2 - ord1)

            local w_count = math.floor(diff / 7)
            local d_rem = diff % 7
            local w_str = string.format("%d周%d天", w_count, d_rem)
            if w_count == 0 then w_str = string.format("%d天", d_rem) end

            local wk_ex, wk_in, nat_days, missing_list = workdays_between(y1, m1, d1, y2, m2, d2)

            -- 候选 1：间隔天数
            yield(Candidate("date_calc", seg.start, seg._end, string.format("%d天", diff), "日期间隔"))
            -- 候选 2：含首尾天数
            yield(Candidate("date_calc", seg.start, seg._end, string.format("%d天（含首尾）", diff + 1), "含首尾"))
            -- 候选 3：工作日计算（若超出节假日数据范围，严格报错，绝不提供错误答案）
            if #missing_list > 0 then
                local tip = string.format("缺少%s年中国节假日数据，无法计算工作日", table.concat(missing_list, "/"))
                yield(Candidate("date_calc", seg.start, seg._end, tip, "〔错误〕"))
            else
                yield(Candidate("date_calc", seg.start, seg._end, string.format("%d个工作日", wk_ex), "工作日"))
                -- 候选 4：含首尾工作日
                yield(Candidate("date_calc", seg.start, seg._end, string.format("%d个工作日（含首尾）", wk_in), "含首尾工作日"))
            end
            -- 候选 5：周+天数
            yield(Candidate("date_calc", seg.start, seg._end, w_str, "周+天数"))
            return
        end
    end

    -- 4. 单个指定日期转换（8位完整日期、4位月日、年初、年末、月初、月末）
    local single_y, single_m, single_d, single_type, single_err = parse_date_token(body, cur_y, cur_m, cur_d)
    if single_err then
        local cand = Candidate("date_calc", seg.start, seg._end, single_err, "〔非法日期〕")
        cand.quality = 1000
        yield(cand)
        return
    end

    if single_y then
        if is_delay_mode then
            local sy, sm, sd, delay_days, err_year = delay_to_next_workday(single_y, single_m, single_d)
            if err_year then
                yield(Candidate("date_calc", seg.start, seg._end, string.format("缺少%d年中国节假日数据，无法计算法定休假日顺延", err_year), "〔错误〕"))
                return
            end
            local comment = (delay_days > 0) and string.format("原%d月%d日休假，顺延至工作日", single_m, single_d) or "法定顺延：已是工作日"
            if single_type == "4digit" then
                yield_four_digit_candidates(yield, seg, sy, sm, sd, comment)
            else
                yield_date_candidates(yield, seg, sy, sm, sd, comment)
            end
        else
            local comment = nil
            if body == "qn" then
                comment = "去年"
            elseif body == "mn" then
                comment = "明年"
            elseif body == "jn" then
                comment = "今年"
            elseif body == "ni" or body == "nc" or body == "jnni" or body == "jnnc" then
                comment = "年初"
            elseif body == "qnni" or body == "qnnc" then
                comment = "去年年初"
            elseif body == "mnni" or body == "mnnc" then
                comment = "明年年初"
            elseif body == "nm" or body == "jnnm" then
                comment = "年末"
            elseif body == "qnnm" then
                comment = "去年年末"
            elseif body == "mnnm" then
                comment = "明年年末"
            elseif body == "yi" or body == "yc" or body == "jnyi" or body == "jnyc" then
                comment = "月初"
            elseif body == "qnyi" or body == "qnyc" then
                comment = "去年月初"
            elseif body == "mnyi" or body == "mnyc" then
                comment = "明年月初"
            elseif body == "ym" or body == "jnym" then
                comment = "月末"
            elseif body == "qnym" then
                comment = "去年月末"
            elseif body == "mnym" then
                comment = "明年月末"
            end

            if single_type == "4digit" then
                yield_four_digit_candidates(yield, seg, single_y, single_m, single_d, comment)
            else
                yield_date_candidates(yield, seg, single_y, single_m, single_d, comment)
            end
        end
        return
    end

    -- 5. 连续多次日期加减运算
    -- 支持 R20260918+30-5, R0101+5, R2024nm+1, Rni+10g, R+10-3+2, R20260131+1m-5, R+15f+3, R+f 等
    local by, bm, bd
    local op_chain

    local op_idx = body:find("[%+%-]")
    if op_idx then
        local base_part = body:sub(1, op_idx - 1)
        op_chain = body:sub(op_idx)
        if base_part == "" then
            by, bm, bd = cur_y, cur_m, cur_d
        else
            local py, pm, pd, ptype, perr = parse_date_token(base_part, cur_y, cur_m, cur_d)
            if perr then
                yield(Candidate("date_calc", seg.start, seg._end, perr, "〔错误〕"))
                return
            end
            if py then
                by, bm, bd = py, pm, pd
            end
        end
    end

    if not by and (body == "f" or body == "+f" or body == "-f") then
        by, bm, bd = cur_y, cur_m, cur_d
        op_chain = "+f"
    end
    if by and op_chain and op_chain:match("^[fs]") then
        op_chain = "+" .. op_chain
    end

    if by and op_chain then
        -- 循环解析连续运算项
        local ops = {}
        local pos = 1
        local len = #op_chain
        local valid = true

        while pos <= len do
            local op, n_str, unit = op_chain:sub(pos):match("^([%+%-]+)(%d+)([nygfsm]?)")
            local match_len
            if op then
                match_len = #op + #n_str + #unit
            else
                op, unit = op_chain:sub(pos):match("^([%+%-]+)([fs])")
                if op then
                    n_str = "0"
                    match_len = #op + #unit
                else
                    valid = false
                    break
                end
            end
            pos = pos + match_len
            local signed = (op:sub(-1) == "+" and 1 or -1) * tonumber(n_str)
            table.insert(ops, {
                op = op,
                num = tonumber(n_str),
                unit = unit,
                signed = signed
            })
        end

        if is_delay_mode then
            -- 若由 RF 前缀触发，且链尾未显式带 f/s，则追加一次最终法定顺延
            local last_op = ops[#ops]
            if not last_op or (last_op.unit ~= "f" and last_op.unit ~= "s") then
                table.insert(ops, {
                    op = "+",
                    num = 0,
                    unit = "f",
                    signed = 0
                })
            end
        end

        if valid and #ops > 0 and pos > len then
            local cy, cm, cd = by, bm, bd
            local is_all_natural = true
            local total_net_natural_days = 0
            local missing_years = {}
            local delay_error_year = nil
            local last_delay_days = 0
            local last_orig_m, last_orig_d = nil, nil
            local last_unit = ""

            for _, item in ipairs(ops) do
                local u = item.unit
                last_unit = u
                if u == "" then
                    cy, cm, cd = add_days(cy, cm, cd, item.signed)
                    total_net_natural_days = total_net_natural_days + item.signed
                elseif u == "y" or u == "m" then
                    cy, cm, cd = add_months(cy, cm, cd, item.signed)
                    is_all_natural = false
                elseif u == "n" then
                    cy, cm, cd = add_years(cy, cm, cd, item.signed)
                    is_all_natural = false
                elseif u == "g" then
                    local ncy, ncm, ncd, miss = add_workdays(cy, cm, cd, item.signed)
                    cy, cm, cd = ncy, ncm, ncd
                    is_all_natural = false
                    for _, my in ipairs(miss) do
                        table.insert(missing_years, my)
                    end
                elseif u == "f" or u == "s" then
                    is_all_natural = false
                    if item.signed ~= 0 then
                        cy, cm, cd = add_days(cy, cm, cd, item.signed)
                    end
                    local om, od = cm, cd
                    local ncy, ncm, ncd, d_days, err_y = delay_to_next_workday(cy, cm, cd)
                    if err_y then
                        delay_error_year = err_y
                        break
                    else
                        cy, cm, cd = ncy, ncm, ncd
                        last_delay_days = d_days
                        last_orig_m, last_orig_d = om, od
                    end
                end
            end

            -- 法定休假日顺延缺少数据判定：严格报错，绝不提供错误答案
            if delay_error_year then
                yield(Candidate("date_calc", seg.start, seg._end, string.format("缺少%d年中国节假日数据，无法计算法定休假日顺延", delay_error_year), "〔错误〕"))
                return
            end

            -- 工作日缺少数据判定
            if #missing_years > 0 then
                local tip = string.format("缺少%s年中国节假日数据", table.concat(missing_years, "/"))
                yield(Candidate("date_calc", seg.start, seg._end, tip, "〔提示〕"))
                return
            end

            -- 纯自然日多次加减，以最终计算的天数为准
            if is_all_natural then
                local special_names = {
                    [1] = "明天",
                    [2] = "后天",
                    [-1] = "昨天",
                    [-2] = "前天",
                    [0] = "今天",
                }
                local special = special_names[total_net_natural_days]
                local comment
                if special and total_net_natural_days ~= 0 then
                    comment = special
                else
                    local sign_str = (total_net_natural_days >= 0) and "+" or ""
                    comment = string.format("%s%d自然日", sign_str, total_net_natural_days)
                end

                yield_date_candidates(yield, seg, cy, cm, cd, comment)
                return
            end

            -- 如果最后一个操作项是法定休假日顺延 (f/s)
            if last_unit == "f" or last_unit == "s" then
                local delay_comment
                if last_delay_days > 0 then
                    delay_comment = string.format("原%d月%d日休假，顺延%d天至工作日", last_orig_m or cm, last_orig_d or cd, last_delay_days)
                else
                    delay_comment = "法定顺延：已是工作日"
                end
                yield_date_candidates(yield, seg, cy, cm, cd, delay_comment)
                return
            end

            -- 其他混合运算（例如以月份 y、年份 n、工作日 g 结尾等）
            local comment = op_chain
            if #ops == 1 then
                local u = ops[1].unit
                local sign_str = (ops[1].signed >= 0) and "+" or "-"
                local abs_n = math.abs(ops[1].signed)
                if u == "y" or u == "m" then
                    comment = string.format("%s%d月", sign_str, abs_n)
                elseif u == "n" then
                    comment = string.format("%s%d年", sign_str, abs_n)
                elseif u == "g" then
                    comment = string.format("%s%d个工作日", (ops[1].signed >= 0) and "+" or "", ops[1].signed)
                end
            else
                comment = op_chain:gsub("(%d+)y", "%1月"):gsub("(%d+)m", "%1月"):gsub("(%d+)n", "%1年"):gsub("(%d+)g", "%1工作日")
            end
            yield_date_candidates(yield, seg, cy, cm, cd, comment)
            return
        end
    end
end

return translator
