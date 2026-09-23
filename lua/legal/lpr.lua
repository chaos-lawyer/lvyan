local set_mode_prompt = require("mode_prompt")

--[[
  lpr.lua
  Rime lua_translator 模块入口
  支持 L 模式（大写 L 或 lpr+Tab）查询 LPR、多倍利率、历史记录与自动更新
--]]

-- 延迟加载 LPR 依赖：避免任一子模块在旧版 librime-lua 中加载失败时，
-- 连带导致整个输入方案无法初始化。首次输入 L/lpr 时才真正加载。
local lpr_data
local lpr_update

local function load_dependencies()
  if lpr_data and lpr_update then
    return true
  end

  local data_ok, data_module = pcall(require, "lpr_data")
  if not data_ok then
    return false, "lpr_data: " .. tostring(data_module)
  end

  local update_ok, update_module = pcall(require, "lpr_update")
  if not update_ok then
    return false, "lpr_update: " .. tostring(update_module)
  end

  lpr_data = data_module
  lpr_update = update_module
  return true
end

-- 格式化百分比数值（支持智能精度：常规2-4位小数，微小日利率等保留至多6位）
local function format_percent(num)
  if not num then return "0.00%" end
  -- 日利率等微小数值（例如 /365 得到的 0.008219%）保留至多 6 位有效小数，且至少 4 位小数（万分位）
  if math.abs(num) < 0.1 and math.abs(num) > 0 then
    local s = string.format("%.6f", num)
    s = s:gsub("(%..-)0+$", "%1")
    s = s:gsub("%.$", "")
    local int_p, dec_p = s:match("^(%-?%d+)%.?(%d*)$")
    if not int_p then return string.format("%.4f%%", num) end
    if #dec_p < 4 then
      dec_p = dec_p .. string.rep("0", 4 - #dec_p)
    end
    return int_p .. "." .. dec_p .. "%"
  end
  -- 常规利率保留 2 位小数，若有额外有效小数保留至多 4 位
  local s = string.format("%.4f", num)
  s = s:gsub("(%..-)0+$", "%1")
  local int_p, dec_p = s:match("^(%-?%d+)%.?(%d*)$")
  if not int_p then return string.format("%.2f%%", num) end
  if #dec_p < 2 then
    dec_p = dec_p .. string.rep("0", 2 - #dec_p)
  end
  return int_p .. "." .. dec_p .. "%"
end

-- 安全执行 LPR 算术表达式（基准利率应用后续计算）
local function eval_lpr_op(base_val, op_expr)
  if not base_val or not op_expr or op_expr == "" then return nil end
  local expr = op_expr:gsub("%s+", "")
  if expr == "" then return nil end

  -- 特殊单位转换：bp (基点) -> *0.01
  expr = expr:gsub("(%d+%.?%d*)%s*[bB][pP]", function(n)
    return "(" .. n .. "*0.01)"
  end)

  -- 加减法后面的 % 视为百分点直接去掉（如 +0.5% 即 +0.5）
  expr = expr:gsub("([%+%-])%s*(%d+%.?%d*)%%", "%1%2")
  -- 乘除法后面的 % 转换为 *0.01（如 *120% 即 *1.2）
  expr = expr:gsub("([%*%/%(])%s*(%d+%.?%d*)%%", function(op, n)
    return op .. "(" .. n .. "*0.01)"
  end)

  -- 构造运算表达式
  local first_char = expr:sub(1, 1)
  local full_code
  if first_char == "+" or first_char == "-" or first_char == "*" or first_char == "/" then
    full_code = tostring(base_val) .. expr
  else
    full_code = tostring(base_val) .. "*" .. expr
  end

  -- 安全沙箱执行求值
  local func, err = load("return " .. full_code, "eval", "t", {})
  if not func then return nil end
  local ok, res = pcall(func)
  if ok and type(res) == "number" and res == res and res ~= math.huge and res ~= -math.huge then
    return res
  end
  return nil
end

-- 生成算式的文书表述与短提示
local function describe_op(op_expr)
  local expr = op_expr:gsub("%s+", "")
  if expr == "/365" then return "除以365（日利率）", "÷365(日利率)" end
  if expr == "/360" then return "除以360（日利率）", "÷360(日利率)" end
  if expr == "/12" then return "除以12（月利率）", "÷12(月利率)" end

  -- 加法：加0.5% 或 加50BP
  local add_num = expr:match("^%+(%d+%.?%d*)%%?$")
  if add_num then
    return "加" .. add_num .. "%", "+" .. add_num .. "%"
  end
  local add_bp = expr:match("^%+(%d+%.?%d*)[bB][pP]$")
  if add_bp then
    return "加" .. add_bp .. "BP", "+" .. add_bp .. "BP"
  end

  -- 减法：减0.2% 或 减20BP
  local sub_num = expr:match("^%-(%d+%.?%d*)%%?$")
  if sub_num then
    return "减" .. sub_num .. "%", "-" .. sub_num .. "%"
  end
  local sub_bp = expr:match("^%-(%d+%.?%d*)[bB][pP]$")
  if sub_bp then
    return "减" .. sub_bp .. "BP", "-" .. sub_bp .. "BP"
  end

  -- 乘法：乘以1.2
  local mul_num = expr:match("^%*(%d+%.?%d*)$")
  if mul_num then
    return "乘以" .. mul_num, "×" .. mul_num
  end

  -- 除法：除以2
  local div_num = expr:match("^%/(%d+%.?%d*)$")
  if div_num then
    return "除以" .. div_num, "÷" .. div_num
  end

  return "按算式(" .. expr .. ")计算", expr
end

-- 金额千分位格式化（保留两位小数）
local function format_currency(num)
  if not num then return "0.00元" end
  local sign = (num < 0) and "-" or ""
  local abs_num = math.abs(num)
  local s = string.format("%.2f", abs_num)
  local int_p, dec_p = s:match("^(%d+)%.(%d+)$")
  local k
  while true do
    int_p, k = int_p:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    if k == 0 then break end
  end
  return sign .. int_p .. "." .. dec_p .. "元"
end

-- 检查算式是否为本息计算（包含万元/亿元或大额本金数值）
local function is_principal_calc(op_expr)
  if not op_expr then return false end
  local expr = op_expr:gsub("%s+", "")
  -- 包含 w/y (万元/亿元)
  if expr:match("[%d%.]+[wyWY]") then
    return true
  end
  -- 包含乘数 >= 100 的数值，例如 *1000, *500000
  for num in expr:gmatch("%*([%d%.]+)") do
    local n = tonumber(num)
    if n and n >= 100 then
      return true
    end
  end
  return false
end

-- 提取算式中的本金数值与展示文本
local function extract_principal(op_expr)
  local expr = op_expr:gsub("%s+", "")
  local p_num, p_unit = expr:match("%*([%d%.]+)([wyWY]?)")
  if p_num then
    local val = tonumber(p_num)
    if val then
      local u = p_unit:lower()
      if u == "w" then
        return val * 10000, p_num .. "万元"
      elseif u == "y" then
        return val * 100000000, p_num .. "亿元"
      elseif val >= 100 then
        return val, tostring(val) .. "元"
      end
    end
  end
  return nil
end

-- 本金本息计算表达式求值（基准利率按真实百分比除以100并展开万元/亿元单位）
local function eval_principal_calc(base_rate, op_expr)
  if not base_rate or not op_expr or op_expr == "" then return nil end
  local expr = op_expr:gsub("%s+", "")
  if expr == "" then return nil end

  -- 替换万元 w, W 为 *(10000)
  expr = expr:gsub("([%d%.]+)[wW]", "(%1*10000)")
  -- 替换亿元 y, Y 为 *(100000000)
  expr = expr:gsub("([%d%.]+)[yY]", "(%1*100000000)")

  -- 利率比例：base_rate / 100
  local rate_ratio = base_rate / 100
  local first_char = expr:sub(1, 1)
  local full_code
  if first_char == "*" or first_char == "/" or first_char == "+" or first_char == "-" then
    full_code = tostring(rate_ratio) .. expr
  else
    full_code = tostring(rate_ratio) .. "*" .. expr
  end

  local fn, err = load("return " .. full_code, "calc", "t", {})
  if not fn then return nil end
  local ok, res = pcall(fn)
  if ok and type(res) == "number" and res == res and res ~= math.huge and res ~= -math.huge then
    return res
  end
  return nil
end

-- 生成以 5 项基础利率为基准的本息计算候选
local function yield_principal_calc_candidates(env, input, seg, rec, op_expr, is_date_query)
  set_mode_prompt(env, seg, "〔LPR本息计算〕")
  local date_tip = is_date_query and ("适用公布日：" .. rec.date) or rec.date

  local p_val, p_text = extract_principal(op_expr)

  local rates = {
    { name = "1年期LPR", val = rec.lpr1y, desc = "一年期贷款市场报价利率（LPR）" },
    { name = "1年期LPR×2", val = rec.lpr1y * 2, desc = "一年期贷款市场报价利率（LPR）的二倍" },
    { name = "1年期LPR×1.5", val = rec.lpr1y * 1.5, desc = "一年期贷款市场报价利率（LPR）的一点五倍" },
    { name = "1年期LPR×4", val = rec.lpr1y * 4, desc = "一年期贷款市场报价利率（LPR）的四倍" },
    { name = "5年期以上LPR", val = rec.lpr5y, desc = "五年期以上贷款市场报价利率（LPR）" },
  }

  local interest_vals = {}
  local all_valid = true
  for i, r in ipairs(rates) do
    local res = eval_principal_calc(r.val, op_expr)
    if res == nil then
      all_valid = false
      break
    end
    interest_vals[i] = res
  end

  -- 如果算式尚未输入完整，在说明区提示并展示基础候选
  if not all_valid then
    set_mode_prompt(env, seg, "〔LPR本息计算：等待输入本金，如 *100w, *1.5y〕")
    yield_standard_10_candidates(input, seg, rec, is_date_query)
    return
  end

  -- 1. 候选 1~5：对应原 1~5 项利率计算出的利息金额（千分位）
  for i, r in ipairs(rates) do
    local int_str = format_currency(interest_vals[i])
    local comment = r.name .. "(" .. format_percent(r.val) .. ")"
    if p_val then
      comment = comment .. "｜本息:" .. format_currency(p_val + interest_vals[i])
    else
      comment = comment .. "｜" .. date_tip
    end
    yield(Candidate("lpr", seg.start, seg._end, int_str, comment))
  end

  -- 2. 候选 6~10：对应原 1~5 项计算出的本息合计金额
  if p_val then
    for i, r in ipairs(rates) do
      local total_str = format_currency(p_val + interest_vals[i])
      yield(Candidate("lpr", seg.start, seg._end, total_str, r.name .. "本息合计｜" .. date_tip))
    end

    -- 3. 候选 11~15：文书规范表述
    for i, r in ipairs(rates) do
      local doc = string.format("以本金%s为基数，按%s（%s）计算利息为%s（本息合计%s）",
        format_currency(p_val), r.desc, format_percent(r.val),
        format_currency(interest_vals[i]), format_currency(p_val + interest_vals[i]))
      yield(Candidate("lpr", seg.start, seg._end, doc, "文书表述"))
    end
  end
end

-- 生成标准 10 候选
local function yield_standard_10_candidates(input, seg, rec, is_date_query)
  local lpr1y_str = format_percent(rec.lpr1y)
  local lpr5y_str = format_percent(rec.lpr5y)
  local lpr1y_x2_str = format_percent(rec.lpr1y * 2)
  local lpr1y_x1_5_str = format_percent(rec.lpr1y * 1.5)
  local lpr1y_x4_str = format_percent(rec.lpr1y * 4)

  local date_tip = is_date_query and ("适用公布日：" .. rec.date) or rec.date

  -- 1. 1年期LPR
  yield(Candidate("lpr", seg.start, seg._end, lpr1y_str, "1年期LPR｜" .. date_tip))
  -- 2. 1年期LPR*2
  yield(Candidate("lpr", seg.start, seg._end, lpr1y_x2_str, "1年期LPR " .. lpr1y_str .. " × 2｜" .. date_tip))
  -- 3. 1年期LPR*1.5
  yield(Candidate("lpr", seg.start, seg._end, lpr1y_x1_5_str, "1年期LPR " .. lpr1y_str .. " × 1.5｜" .. date_tip))
  -- 4. 一年期LPR*4
  yield(Candidate("lpr", seg.start, seg._end, lpr1y_x4_str, "1年期LPR " .. lpr1y_str .. " × 4｜" .. date_tip))
  -- 5. 五年期以上LPR
  yield(Candidate("lpr", seg.start, seg._end, lpr5y_str, "5年期以上LPR｜" .. date_tip))
  -- 6. 第1项文字表述
  yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）为" .. lpr1y_str, "文书表述"))
  -- 7. 第2项文字表述
  yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）的二倍为" .. lpr1y_x2_str, "文书表述"))
  -- 8. 第3项文字表述
  yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）的一点五倍为" .. lpr1y_x1_5_str, "文书表述"))
  -- 9. 第4项文字表述
  yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）的四倍为" .. lpr1y_x4_str, "文书表述"))
  -- 10. 第5项文字表述
  yield(Candidate("lpr", seg.start, seg._end, "五年期以上贷款市场报价利率（LPR）为" .. lpr5y_str, "文书表述"))
end

-- 生成各项基础利率根据算式计算后的 10 候选
local function yield_calc_candidates(env, input, seg, rec, op_expr, is_date_query)
  local cn_desc, short_desc = describe_op(op_expr)
  local date_tip = is_date_query and ("适用公布日：" .. rec.date) or rec.date

  local res1y = eval_lpr_op(rec.lpr1y, op_expr)
  local res1y_x2 = eval_lpr_op(rec.lpr1y * 2, op_expr)
  local res1y_x1_5 = eval_lpr_op(rec.lpr1y * 1.5, op_expr)
  local res1y_x4 = eval_lpr_op(rec.lpr1y * 4, op_expr)
  local res5y = eval_lpr_op(rec.lpr5y, op_expr)

  -- 如果算式尚未输入完整（例如刚输入了 +、-、*、/），在说明区提示等待输入数值，候选区展示基础 10 项候选
  if not res1y or not res1y_x2 or not res1y_x1_5 or not res1y_x4 or not res5y then
    set_mode_prompt(env, seg, "〔LPR计算：等待输入数值，如 " .. op_expr .. "0.5, " .. op_expr .. "1.2, /365〕")
    yield_standard_10_candidates(input, seg, rec, is_date_query)
    return
  end

  local str1y = format_percent(res1y)
  local str1y_x2 = format_percent(res1y_x2)
  local str1y_x1_5 = format_percent(res1y_x1_5)
  local str1y_x4 = format_percent(res1y_x4)
  local str5y = format_percent(res5y)

  -- 1. 1年期LPR + 算式计算结果
  yield(Candidate("lpr", seg.start, seg._end, str1y, "1年期LPR " .. short_desc .. "｜" .. date_tip))
  -- 2. 1年期LPR*2 + 算式计算结果
  yield(Candidate("lpr", seg.start, seg._end, str1y_x2, "1年期LPR×2 " .. short_desc .. "｜" .. date_tip))
  -- 3. 1年期LPR*1.5 + 算式计算结果
  yield(Candidate("lpr", seg.start, seg._end, str1y_x1_5, "1年期LPR×1.5 " .. short_desc .. "｜" .. date_tip))
  -- 4. 1年期LPR*4 + 算式计算结果
  yield(Candidate("lpr", seg.start, seg._end, str1y_x4, "1年期LPR×4 " .. short_desc .. "｜" .. date_tip))
  -- 5. 5年期以上LPR + 算式计算结果
  yield(Candidate("lpr", seg.start, seg._end, str5y, "5年期以上LPR " .. short_desc .. "｜" .. date_tip))

  -- 6. 第1项文字表述
  yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）" .. cn_desc .. "为" .. str1y, "文书表述"))
  -- 7. 第2项文字表述
  yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）的二倍" .. cn_desc .. "为" .. str1y_x2, "文书表述"))
  -- 8. 第3项文字表述
  yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）的一点五倍" .. cn_desc .. "为" .. str1y_x1_5, "文书表述"))
  -- 9. 第4项文字表述
  yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）的四倍" .. cn_desc .. "为" .. str1y_x4, "文书表述"))
  -- 10. 第5项文字表述
  yield(Candidate("lpr", seg.start, seg._end, "五年期以上贷款市场报价利率（LPR）" .. cn_desc .. "为" .. str5y, "文书表述"))
end

-- 生成单项倍数加算式的候选
local function yield_mult_calc_candidates(env, input, seg, rec, mult_val, mult_key, op_expr)
  local cn_desc, short_desc = describe_op(op_expr)
  local base_val = rec.lpr1y * mult_val
  local res_val = eval_lpr_op(base_val, op_expr)

  local cn_names = { ["1"] = "一倍", ["2"] = "二倍", ["1.5"] = "一点五倍", ["4"] = "四倍" }
  local cn_name = cn_names[mult_key] or (mult_key .. "倍")

  if not res_val then
    set_mode_prompt(env, seg, "〔LPR计算：等待输入数值，如 " .. mult_key .. op_expr .. "0.5〕")
    return
  end

  local res_str = format_percent(res_val)

  yield(Candidate("lpr", seg.start, seg._end, res_str, "1年期LPR×" .. mult_key .. " " .. short_desc .. "｜" .. rec.date))
  if mult_key == "1" then
    yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）" .. cn_desc .. "为" .. res_str, "文书表述"))
    yield(Candidate("lpr", seg.start, seg._end, "1年期LPR" .. cn_desc .. "：" .. res_str, "文书表述"))
  else
    yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）的" .. cn_name .. cn_desc .. "为" .. res_str, "文书表述"))
    yield(Candidate("lpr", seg.start, seg._end, "1年期LPR" .. cn_name .. cn_desc .. "：" .. res_str, "文书表述"))
  end
end

local function translator(input, seg, env)
  -- 检查输入是否以 L 开头（仅响应 lpr+Tab 引导）
  local cmd = nil
  if input:match("^L(.*)$") then
    cmd = input:sub(2)
  else
    return
  end

  local context = env.engine and env.engine.context
  local tab_mode = context and context:get_property("tab_mode") or ""
  if tab_mode ~= "lpr" then
    return
  end

  -- 设置说明提示
  set_mode_prompt(env, seg, "〔LPR计算〕")

  local loaded, load_error = load_dependencies()
  if not loaded then
    yield(Candidate("lpr", seg.start, seg._end, "LPR模块加载失败", load_error))
    return
  end

  local lower_cmd = cmd:lower()

  -- 无论使用哪个 LPR 指令，都先应用后台已经下载完成的数据，避免继续显示旧缓存。
  pcall(lpr_update.check_and_apply_tmp)

  -- 手动更新指令：Lgx / lprgx
  if lower_cmd == "gx" then
    lpr_update.trigger_update(true)
    yield(Candidate("lpr", seg.start, seg._end, "已请求检查 LPR 更新", "后台异步更新中，稍后生效"))
    return
  end

  -- 3. 指定日期 + 后续计算：例如 L20220830+0.5, L20220830/365, L20220830*1.2, L20220830*100w
  local date_part, date_op = cmd:match("^(%d%d%d%d%d%d%d%d)([%+%-%*%/].*)$")
  if date_part and date_op then
    local rec, norm_date = lpr_data.get_lpr_by_date(date_part)
    if rec then
      if is_principal_calc(date_op) then
        yield_principal_calc_candidates(env, input, seg, rec, date_op, true)
      else
        yield_calc_candidates(env, input, seg, rec, date_op, true)
      end
    else
      yield(Candidate("lpr", seg.start, seg._end, "未找到 " .. date_part .. " 的LPR记录", "历史数据始于2019年8月"))
    end
    return
  end

  -- 4. 单项倍数 + 后续计算：例如 L4+0.5, L2*1.2, L1.5+0.5, L1/365
  local mult_part, mult_op = cmd:match("^(%d+%.?%d*)([%+%-%*%/].*)$")
  if mult_part and mult_op and (mult_part == "1" or mult_part == "2" or mult_part == "1.5" or mult_part == "4") then
    local latest = lpr_data.get_latest_lpr()
    if latest then
      yield_mult_calc_candidates(env, input, seg, latest, tonumber(mult_part), mult_part, mult_op)
    end
    return
  end

  -- 5. 当前最新 LPR + 后续计算：例如 L+0.5, L-0.2, L*1.2, L/365, L*100w, L*1.5y
  local op_only = cmd:match("^([%+%-%*%/].*)$")
  if op_only then
    local latest = lpr_data.get_latest_lpr()
    if latest then
      if is_principal_calc(op_only) then
        yield_principal_calc_candidates(env, input, seg, latest, op_only, false)
      else
        yield_calc_candidates(env, input, seg, latest, op_only, false)
      end
    else
      yield(Candidate("lpr", seg.start, seg._end, "LPR数据读取中", "请稍候"))
    end
    return
  end

  -- 6. 倍数快捷查询：L4 / L2 / L1.5
  if cmd == "4" or cmd == "2" or cmd == "1.5" or cmd == "1" then
    local latest = lpr_data.get_latest_lpr()
    if not latest then return end
    local mult = tonumber(cmd) or 1
    local mult_str = format_percent(latest.lpr1y * mult)
    local lpr1y_str = format_percent(latest.lpr1y)

    local cn_names = { ["1"] = "一倍", ["2"] = "二倍", ["1.5"] = "一点五倍", ["4"] = "四倍" }
    local cn_name = cn_names[cmd] or (cmd .. "倍")

    yield(Candidate("lpr", seg.start, seg._end, mult_str, "1年期LPR " .. lpr1y_str .. " × " .. cmd .. "｜" .. latest.date))
    yield(Candidate("lpr", seg.start, seg._end, "一年期贷款市场报价利率（LPR）的" .. cn_name .. "为" .. mult_str, "文书表述"))
    yield(Candidate("lpr", seg.start, seg._end, "1年期LPR" .. cn_name .. "：" .. mult_str, "文书表述"))
    return
  end

  -- 4. 具体日期适用查询：8位数字 YYYYMMDD (例如 L20220830)
  local ymd = cmd:match("^(%d%d%d%d%d%d%d%d)$")
  if ymd then
    local rec, norm_date = lpr_data.get_lpr_by_date(ymd)
    if rec then
      yield_standard_10_candidates(input, seg, rec, true)
    end
    return
  end

  -- 5. 年月查询：6位数字 YYYYMM (例如 L202208)
  local ym = cmd:match("^(%d%d%d%d%d%d)$")
  if ym then
    local records = lpr_data.get_records_by_year_month(ym)
    if #records > 0 then
      for _, r in ipairs(records) do
        local cand_text = string.format("%s｜1年期%.2f%%｜5年以上%.2f%%", r.date, r.lpr1y, r.lpr5y)
        yield(Candidate("lpr", seg.start, seg._end, cand_text, "当月LPR"))
      end
    else
      -- 该月若无新公布记录，查该月最后一日适用记录
      local rec = lpr_data.get_lpr_by_date(ym .. "28")
      if rec then
        yield(Candidate("lpr", seg.start, seg._end, "该月未公布LPR，适用公布日：" .. rec.date, string.format("1年期:%.2f%% 5年期:%.2f%%", rec.lpr1y, rec.lpr5y)))
      end
    end
    return
  end

  -- 6. 年份历史查询：4位数字 YYYY (例如 L2022)
  local year = cmd:match("^(%d%d%d%d)$")
  if year then
    local records = lpr_data.get_records_by_year(year)
    if #records > 0 then
      for _, r in ipairs(records) do
        local cand_text = string.format("%s｜1年期%.2f%%｜5年以上%.2f%%", r.date, r.lpr1y, r.lpr5y)
        yield(Candidate("lpr", seg.start, seg._end, cand_text, "历史LPR"))
      end
    else
      yield(Candidate("lpr", seg.start, seg._end, year .. "年无LPR记录", "历史数据始于2019年8月"))
    end
    return
  end

  -- 7. 默认当前 LPR 模式：输入为 L 或 lpr (cmd 为空)
  if cmd == "" then
    -- 在读取候选前评估更新。若后台维护处理器已完成预下载，这里会先应用并立即显示新值；
    -- 若本次才开始异步下载，则本次仍显示带公布日期的本地值，后续输入会应用下载结果。
    lpr_update.trigger_update(false)
    local latest = lpr_data.get_latest_lpr()
    if latest then
      yield_standard_10_candidates(input, seg, latest, false)
    else
      yield(Candidate("lpr", seg.start, seg._end, "LPR数据读取中", "请稍候"))
    end
    return
  end
end

return translator
