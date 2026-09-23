local set_mode_prompt = require("mode_prompt")

-- v_expression_translator.lua
-- V 键三合一调度翻译器：
-- 1. 纯数字时：走数字转换（壹仟贰佰叁拾肆 / 一千二百三十四 / 1,234）
-- 2. 包含小数点时：走金额转换（壹仟贰佰叁拾肆元壹角贰分 / 1,234.12元；整数显示为“……元整”）
-- 3. 出现运算符时：切到计算器，计算表达式并输出结果

local digits_lower = {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
local units_lower  = {"", "十", "百", "千"}
local big_units_lower = {"", "万", "亿", "兆"}

local digits_upper = {"零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"}
local units_upper  = {"", "拾", "佰", "仟"}
local big_units_upper = {"", "万", "亿", "兆"}

-- 千分位格式化
local function format_thousands(num_str)
  local left, dot, right = num_str:match("^([+-]?%d+)(%.?)(%d*)$")
  if not left then return num_str end
  local k
  while true do
    left, k = left:gsub("^([+-]?%d+)(%d%d%d)", "%1,%2")
    if k == 0 then break end
  end
  if dot ~= "" and #right > 0 then
    return left .. "." .. right
  else
    return left
  end
end

-- 字符串小数位移（用于万元 w -> 小数点右移4位，亿元 y -> 小数点右移8位）
local function shift_decimal(str, shift)
  local int_part, dot, dec_part = str:match("^(%d*)(%.?)(%d*)$")
  int_part = int_part or ""
  dec_part = dec_part or ""
  if int_part == "" and dec_part == "" then return "0", "" end

  if #dec_part < shift then
    int_part = int_part .. dec_part .. string.rep("0", shift - #dec_part)
    dec_part = ""
  else
    int_part = int_part .. dec_part:sub(1, shift)
    dec_part = dec_part:sub(shift + 1)
  end
  int_part = int_part:gsub("^0+", "")
  if int_part == "" then int_part = "0" end
  return int_part, dec_part
end

-- 整数转换为中文汉字数字（大写或小写）
local function int_to_chinese(num_str, is_upper)
  local digits = is_upper and digits_upper or digits_lower
  local units = is_upper and units_upper or units_lower
  local big_units = is_upper and big_units_upper or big_units_lower

  num_str = num_str:gsub("^0+", "")
  if num_str == "" then return digits[1] end
  if #num_str > 16 then return "数值超限" end

  local function section_to_cn(sec)
    local val = tonumber(sec)
    local res = ""
    local pos = 1
    local pending_zero = false
    while val > 0 do
      local d = val % 10
      if d == 0 then
        if res ~= "" then pending_zero = true end
      else
        local p = digits[d + 1] .. units[pos]
        if pending_zero then p = p .. digits[1] end
        res = p .. res
        pending_zero = false
      end
      val = math.floor(val / 10)
      pos = pos + 1
    end
    return res
  end

  local sections = {}
  local cursor = #num_str
  while cursor > 0 do
    local first = math.max(1, cursor - 3)
    table.insert(sections, 1, num_str:sub(first, cursor))
    cursor = first - 1
  end

  local result = ""
  local pending_zero = false
  for i, sec in ipairs(sections) do
    local val = tonumber(sec)
    if val == 0 then
      if result ~= "" then pending_zero = true end
    else
      if result ~= "" and (pending_zero or val < 1000) then
        result = result .. digits[1]
      end
      result = result .. section_to_cn(sec) .. big_units[#sections - i + 1]
      pending_zero = false
    end
  end

  -- 小写时十位 10-19 读作“十”而不是“一十”
  if not is_upper then
    result = result:gsub("^一十", "十")
  end

  return result
end

-- 金额大写转换（包含元、角、分、整）
local function to_rmb_upper(int_str, dec_str)
  local cn_int = int_to_chinese(int_str, true)
  if cn_int == "数值超限" then return "数值超限" end

  local rmb_str = cn_int .. "元"
  dec_str = (dec_str or ""):sub(1, 2)

  local jiao = tonumber(dec_str:sub(1, 1)) or 0
  local fen = tonumber(dec_str:sub(2, 2)) or 0

  if jiao == 0 and fen == 0 then
    rmb_str = rmb_str .. "整"
  elseif jiao > 0 and fen == 0 then
    rmb_str = rmb_str .. digits_upper[jiao + 1] .. "角整"
  elseif jiao == 0 and fen > 0 then
    rmb_str = rmb_str .. "零" .. digits_upper[fen + 1] .. "分"
  else
    rmb_str = rmb_str .. digits_upper[jiao + 1] .. "角" .. digits_upper[fen + 1] .. "分"
  end

  return rmb_str
end

-- 小数点读法（如 1234.12 -> 一千二百三十四点一二）
local function to_chinese_decimal(int_str, dec_str, is_upper)
  local digits = is_upper and digits_upper or digits_lower
  local int_part = int_to_chinese(int_str, is_upper)
  local dec_part = ""
  for i = 1, #dec_str do
    local d = tonumber(dec_str:sub(i, i))
    if d then dec_part = dec_part .. digits[d + 1] end
  end
  return int_part .. "点" .. dec_part
end

-- 计算器执行环境
local calc_env = {
  abs = math.abs,
  sqrt = math.sqrt,
  sin = math.sin,
  cos = math.cos,
  tan = math.tan,
  exp = math.exp,
  log = math.log,
  floor = math.floor,
  ceil = math.ceil,
  pi = math.pi,
  e = math.exp(1),
}

local function eval_expression(expr)
  -- 简单转义处理百分号：% 转换为 *0.01（当后面不跟运算符或数字时）
  local code = expr:gsub("([%d%.]+)%%", "(%1*0.01)")
  -- 支持万元(w/wy)与亿元(y/yy)
  code = code:gsub("([%d%.]+)[wW][yY]", "(%1*10000)")
  code = code:gsub("([%d%.]+)[yY][yY]", "(%1*100000000)")
  code = code:gsub("([%d%.]+)[wW]", "(%1*10000)")
  code = code:gsub("([%d%.]+)[yY]", "(%1*100000000)")
  -- 处理阶乘如 5!
  code = code:gsub("(%d+)!+", function(n)
    local val = tonumber(n) or 0
    local f = 1
    for i = 2, val do f = f * i end
    return tostring(f)
  end)

  local fn, err = load("return " .. code, "calc", "t", calc_env)
  if not fn then return nil end
  local ok, res = pcall(fn)
  if not ok or res == nil then return nil end
  return res
end

-- 生成计算结果的金额表示候选
local function yield_amount_candidates(result, seg, expr_str)
  local is_neg = false
  local num_val = tonumber(result)
  if not num_val then return end

  if num_val < 0 then
    is_neg = true
    num_val = math.abs(num_val)
  end

  local int_part, dec_part
  if math.abs(num_val - math.floor(num_val)) < 1e-9 then
    int_part = string.format("%d", math.floor(num_val))
    dec_part = ""
  else
    local rounded = math.floor(num_val * 100 + 0.5) / 100
    int_part = string.format("%d", math.floor(rounded))
    dec_part = string.format("%02d", math.floor((rounded * 100 + 0.5) % 100))
    if dec_part == "00" then
      dec_part = ""
    end
  end

  -- 1. 金额大写
  local rmb_upper = to_rmb_upper(int_part, dec_part)
  if rmb_upper ~= "数值超限" and is_neg then
    rmb_upper = "负" .. rmb_upper
  end
  yield(Candidate("v_calc", seg.start, seg._end, rmb_upper, "〔金额大写〕"))

  -- 2. 金额数值
  local thousands_val
  if dec_part ~= "" then
    thousands_val = format_thousands(int_part) .. "." .. dec_part .. "元"
  else
    thousands_val = format_thousands(int_part) .. "元"
  end
  if is_neg then
    thousands_val = "-" .. thousands_val
  end
  yield(Candidate("v_calc", seg.start, seg._end, thousands_val, "〔金额数值〕"))

  -- 3. 数字读法
  local cn_reading
  if dec_part ~= "" then
    cn_reading = to_chinese_decimal(int_part, dec_part, false) .. "元"
  else
    cn_reading = int_to_chinese(int_part, false) .. "元"
  end
  if is_neg then
    cn_reading = "负" .. cn_reading
  end
  yield(Candidate("v_calc", seg.start, seg._end, cn_reading, "〔数字读法〕"))

  -- 4. 计算结果
  local res_str
  if dec_part ~= "" then
    res_str = int_part .. "." .. dec_part
  else
    res_str = int_part
  end
  if is_neg then
    res_str = "-" .. res_str
  end
  yield(Candidate("v_calc", seg.start, seg._end, res_str, "〔计算结果〕"))

  -- 5. 算式
  if expr_str and expr_str ~= "" then
    yield(Candidate("v_calc", seg.start, seg._end, expr_str .. "=" .. res_str, "〔算式〕"))
  end
end

local function translator(input, seg, env)
  -- 匹配大写 V 开头的输入（响应 v+Tab 或大写 V 引导）
  local expr = input:match("^V(.*)$")
  if not expr then return end

  local context = env.engine and env.engine.context
  local tab_mode = context and context:get_property("tab_mode") or ""
  if tab_mode ~= "v" then
    return
  end

  local is_amount_mode = false
  local core_expr = expr
  if core_expr:match("[¥$]$") then
    is_amount_mode = true
    core_expr = core_expr:gsub("[¥$]+$", "")
  elseif core_expr:match("^[¥$]") then
    is_amount_mode = true
    core_expr = core_expr:gsub("^[¥$]+", "")
  end

  if is_amount_mode then
    set_mode_prompt(env, seg, "〔金额计算〕")
  else
    set_mode_prompt(env, seg, "〔数字/金额/计算器〕")
  end

  if core_expr == "" then
    return
  end

  -- 1. 检查是否包含运算符：+ - * / % ^ ( ) 等
  -- 包含运算符则切入【计算器模式】
  local has_operator = core_expr:find("[%+%-%*%/%%%^%(%)]")
  if has_operator then
    local result = eval_expression(core_expr)
    if result ~= nil then
      if is_amount_mode then
        yield_amount_candidates(result, seg, core_expr)
        return
      end

      local res_str
      if type(result) == "number" then
        if math.abs(result - math.floor(result)) < 1e-9 then
          res_str = string.format("%d", math.floor(result))
        else
          res_str = tostring(result):gsub("%.?0+$", "")
        end
      else
        res_str = tostring(result)
      end
      yield(Candidate("v_calc", seg.start, seg._end, res_str, "〔计算结果〕"))
      yield(Candidate("v_calc", seg.start, seg._end, core_expr .. "=" .. res_str, "〔算式〕"))

      -- 候选 3：千分符结果（如果结果小于四位数则不显示）
      local int_digits = res_str:match("^[+-]?(%d+)")
      if int_digits and #int_digits >= 4 then
        local thousand_res = format_thousands(res_str)
        yield(Candidate("v_calc", seg.start, seg._end, thousand_res, "〔千分符〕"))
      end
    end
    return
  end

  -- 2. 检查是否带万元/亿元后缀：w/W/wy/WY (万), y/Y/yy/YY (亿)
  -- 例如：V123w / V123wy -> 壹佰贰拾叁万元整；V1234.23w -> 壹仟贰佰叁拾肆万贰仟叁佰元整；V1.5y / V1.5yy -> 壹亿伍仟万元整
  local num_part, unit = core_expr:match("^([%d%.]+)([wWyY][yY]?)$")
  if num_part and (num_part:match("^%d+%.?%d*$") or num_part:match("^%d*%.%d+$")) and num_part:gsub("%.", "") ~= "" then
    local u = unit:lower()
    local shift = (u == "w" or u == "wy") and 4 or 8
    local int_part, dec_part = shift_decimal(num_part, shift)

    if dec_part == "" then
      -- 转换后为纯整数（例如 V123w -> 1230000；V1234.23w -> 12342300；V1.5y -> 150000000）
      -- 候选 1：大写金额整（例如：壹佰贰拾叁万元整、壹仟贰佰叁拾肆万贰仟叁佰元整）
      local rmb_upper = to_rmb_upper(int_part, "")
      yield(Candidate("v_number", seg.start, seg._end, rmb_upper, "〔金额大写〕"))

      -- 候选 2：千分位金额（例如：1,230,000元、12,342,300元）
      local thousand_num = format_thousands(int_part)
      yield(Candidate("v_number", seg.start, seg._end, thousand_num .. "元", "〔金额数值〕"))

      -- 候选 3：中文读法（例如：一百二十三万元、一千二百三十四万二千三百元）
      local lower_cn = int_to_chinese(int_part, false)
      yield(Candidate("v_number", seg.start, seg._end, lower_cn .. "元", "〔数字读法〕"))

      -- 候选 4：大写数字（例如：壹佰贰拾叁万、壹仟贰佰叁拾肆万贰仟叁佰）
      local upper_cn = int_to_chinese(int_part, true)
      yield(Candidate("v_number", seg.start, seg._end, upper_cn, "〔数字大写〕"))

      -- 候选 5：千分位纯数字（例如：1,230,000、12,342,300）
      yield(Candidate("v_number", seg.start, seg._end, thousand_num, "〔千分位〕"))
      return
    else
      -- 转换后仍包含小数（例如 V1.23456w -> 12345.6）
      -- 候选 1：大写人民币金额（例如：壹万贰仟叁佰肆拾伍元陆角）
      local rmb_upper = to_rmb_upper(int_part, dec_part)
      yield(Candidate("v_number", seg.start, seg._end, rmb_upper, "〔金额大写〕"))

      -- 候选 2：千分位金额（例如：12,345.60元）
      local thousands_val = format_thousands(int_part) .. "." .. dec_part .. "元"
      yield(Candidate("v_number", seg.start, seg._end, thousands_val, "〔金额数值〕"))

      -- 候选 3：汉字小数小写读法（例如：一万二千三百四十五点六元）
      local cn_dec = to_chinese_decimal(int_part, dec_part, false) .. "元"
      yield(Candidate("v_number", seg.start, seg._end, cn_dec, "〔数字读法〕"))

      -- 候选 4：汉字小数大写读法（例如：壹万贰仟叁佰肆拾伍点陆）
      local cn_upper_dec = to_chinese_decimal(int_part, dec_part, true)
      yield(Candidate("v_number", seg.start, seg._end, cn_upper_dec, "〔数字大写〕"))
      return
    end
  end

  -- 3. 检查是否为金额转换模式：包含小数点且主体是数字
  local dot_pos = core_expr:find("%.")
  if dot_pos then
    local int_part, dec_part = core_expr:match("^(%d*)%.(%d*)$")
    if int_part then
      if int_part == "" then int_part = "0" end
      -- 候选 1：大写人民币金额（例如：壹仟贰佰叁拾肆元壹角贰分；整数或纯零则为“……元整”）
      local rmb_upper = to_rmb_upper(int_part, dec_part)
      yield(Candidate("v_number", seg.start, seg._end, rmb_upper, "〔金额大写〕"))

      -- 候选 2：千分位金额（例如：1,234.12元）
      local thousands_val
      if dec_part and #dec_part > 0 then
        thousands_val = format_thousands(int_part) .. "." .. dec_part .. "元"
      else
        thousands_val = format_thousands(int_part) .. "元"
      end
      yield(Candidate("v_number", seg.start, seg._end, thousands_val, "〔金额数值〕"))

      -- 候选 3：汉字小数小写读法（如：一千二百三十四点一二）
      if dec_part and #dec_part > 0 then
        local cn_dec = to_chinese_decimal(int_part, dec_part, false)
        yield(Candidate("v_number", seg.start, seg._end, cn_dec, "〔数字读法〕"))
      end
      return
    end
  end

  -- 4. 纯数字模式：只包含纯阿拉伯数字
  local pure_num = core_expr:match("^(%d+)$")
  if pure_num then
    local upper_cn = int_to_chinese(pure_num, true)
    local lower_cn = int_to_chinese(pure_num, false)
    local thousand_num = format_thousands(pure_num)
    local rmb_whole = to_rmb_upper(pure_num, "")

    if is_amount_mode then
      yield(Candidate("v_number", seg.start, seg._end, rmb_whole, "〔金额大写〕"))
      yield(Candidate("v_number", seg.start, seg._end, thousand_num .. "元", "〔金额数值〕"))
      yield(Candidate("v_number", seg.start, seg._end, lower_cn .. "元", "〔数字读法〕"))
      yield(Candidate("v_number", seg.start, seg._end, upper_cn, "〔数字大写〕"))
      yield(Candidate("v_number", seg.start, seg._end, thousand_num, "〔千分位〕"))
    else
      -- 候选 1：大写数字（壹仟贰佰叁拾肆）
      yield(Candidate("v_number", seg.start, seg._end, upper_cn, "〔数字大写〕"))

      -- 候选 2：小写数字（一千二百三十四）
      yield(Candidate("v_number", seg.start, seg._end, lower_cn, "〔数字小写〕"))

      -- 候选 3：千分位数字（1,234）
      yield(Candidate("v_number", seg.start, seg._end, thousand_num, "〔千分位〕"))

      -- 候选 4：大写金额整（壹仟贰佰叁拾肆元整）
      yield(Candidate("v_number", seg.start, seg._end, rmb_whole, "〔金额大写〕"))

      -- 候选 5：金额千分位（1,234元）
      yield(Candidate("v_number", seg.start, seg._end, thousand_num .. "元", "〔金额数值〕"))
    end
    return
  end
end

return translator
