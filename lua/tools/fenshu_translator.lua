local set_mode_prompt = require("mode_prompt")

--[[
  fenshu_translator.lua
  合同文本份数模式翻译器（壹式N份）
  启动方式：
    全拼方案：ys + Tab (yī shì 一式)
    小鹤双拼：yu + Tab (y=y, u=sh -> yī shì)
  输入格式与功能：
    1. 纯数字 N（默认双方）：
       - 偶数（如 4）：生成"壹式肆份，甲乙双方各执贰份"及效力条款
       - 奇数（如 5）：生成"壹式伍份，甲方执叁份，乙方执贰份"与"甲方执贰份，乙方执叁份"等
    2. 除号均分 N/K（如 10/5）：
       - 各方均分生成"壹式拾份，各方各执贰份"（2方为甲乙双方，3方为甲乙丙三方）
    3. 减号或点号指定分配 N-A 或 N.A 或 N-A-B（如 10-2、10.2、10-2-4）：
       - 自动推定余方持有份数并按天干序排列生成规范表述
--]]

local digits = {"零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"}

local function to_upper_num(n)
  n = tonumber(n)
  if not n or n < 0 then return "" end
  if n <= 9 then
    return digits[n + 1]
  elseif n == 10 then
    return "拾"
  elseif n < 20 then
    return "拾" .. digits[(n % 10) + 1]
  elseif n < 100 then
    local tens = math.floor(n / 10)
    local ones = n % 10
    local s = digits[tens + 1] .. "拾"
    if ones > 0 then
      s = s .. digits[ones + 1]
    end
    return s
  elseif n < 1000 then
    local hundreds = math.floor(n / 100)
    local rem = n % 100
    local s = digits[hundreds + 1] .. "佰"
    if rem == 0 then
      return s
    elseif rem < 10 then
      return s .. "零" .. digits[rem + 1]
    elseif rem < 20 then
      return s .. "壹拾" .. (rem > 10 and digits[(rem % 10) + 1] or "")
    else
      local tens = math.floor(rem / 10)
      local ones = rem % 10
      s = s .. digits[tens + 1] .. "拾"
      if ones > 0 then s = s .. digits[ones + 1] end
      return s
    end
  else
    return tostring(n)
  end
end

local party_names = {
  "甲方", "乙方", "丙方", "丁方", "戊方",
  "己方", "庚方", "辛方", "壬方", "癸方"
}

local function translator(input, seg, env)
  local expr = input:match("^Ys(.*)$")
  if not expr then return end

  local context = env.engine and env.engine.context
  local tab_mode = context and context:get_property("tab_mode") or ""
  if tab_mode ~= "fenshu" then
    return
  end

  set_mode_prompt(env, seg, "〔文本份数〕")

  if expr == "" then
    return
  end

  -- 模式 2：除号均分 N/K（如 10/5、10/2、9/3）
  local total_div, parties_div = expr:match("^(%d+)/(%d+)$")
  if total_div and parties_div then
    local N = tonumber(total_div)
    local K = tonumber(parties_div)
    if not N or not K or N <= 0 or K <= 0 then return end

    local n_cn = to_upper_num(N)
    local prefix = "壹式" .. n_cn .. "份，"

    if K == 1 then
      yield(Candidate("fenshu", seg.start, seg._end, "壹式" .. n_cn .. "份，由甲方执" .. n_cn .. "份", "〔独执〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "本合同壹式" .. n_cn .. "份，由甲方执" .. n_cn .. "份，具有同等法律效力。", "〔合同条款〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "壹式" .. n_cn .. "份", "〔纯份数〕"))
      return
    end

    if N % K == 0 then
      local share = N / K
      local share_cn = to_upper_num(share)

      if K == 2 then
        yield(Candidate("fenshu", seg.start, seg._end, prefix .. "甲乙双方各执" .. share_cn .. "份", "〔双方执〕"))
        yield(Candidate("fenshu", seg.start, seg._end, "本合同" .. prefix .. "甲乙双方各执" .. share_cn .. "份，具有同等法律效力。", "〔合同条款〕"))
      elseif K == 3 then
        yield(Candidate("fenshu", seg.start, seg._end, prefix .. "甲乙丙三方各执" .. share_cn .. "份", "〔三方执〕"))
        yield(Candidate("fenshu", seg.start, seg._end, prefix .. "各方各执" .. share_cn .. "份", "〔各方执〕"))
        yield(Candidate("fenshu", seg.start, seg._end, "本合同" .. prefix .. "各方各执" .. share_cn .. "份，具有同等法律效力。", "〔合同条款〕"))
      else
        yield(Candidate("fenshu", seg.start, seg._end, prefix .. "各方各执" .. share_cn .. "份", "〔各方执〕"))
        yield(Candidate("fenshu", seg.start, seg._end, "本合同" .. prefix .. "各方各执" .. share_cn .. "份，具有同等法律效力。", "〔合同条款〕"))
      end
      yield(Candidate("fenshu", seg.start, seg._end, "壹式" .. n_cn .. "份", "〔纯份数〕"))
      return
    else
      -- 不能整除时，计算多出份额分配方案
      local base = math.floor(N / K)
      local rem = N % K
      local base_cn = to_upper_num(base)
      local more_cn = to_upper_num(base + 1)

      -- 方案 1：前 rem 方各执 base+1 份，后续方各执 base 份
      local items_zhi_1 = {}
      for i = 1, K do
        local p = party_names[i] or ("第" .. i .. "方")
        local count_cn = (i <= rem) and more_cn or base_cn
        table.insert(items_zhi_1, p .. "执" .. count_cn .. "份")
      end
      local clause_zhi_1 = table.concat(items_zhi_1, "，")

      yield(Candidate("fenshu", seg.start, seg._end, prefix .. clause_zhi_1, "〔前多后少〕"))

      -- 方案 2：前 K-rem 方各执 base 份，后 rem 方各执 base+1 份
      local items_zhi_2 = {}
      for i = 1, K do
        local p = party_names[i] or ("第" .. i .. "方")
        local count_cn = (i <= (K - rem)) and base_cn or more_cn
        table.insert(items_zhi_2, p .. "执" .. count_cn .. "份")
      end
      local clause_zhi_2 = table.concat(items_zhi_2, "，")
      yield(Candidate("fenshu", seg.start, seg._end, prefix .. clause_zhi_2, "〔前少后多〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "本合同" .. prefix .. clause_zhi_1 .. "，具有同等法律效力。", "〔合同条款〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "壹式" .. n_cn .. "份", "〔纯份数〕"))
      return
    end
  end

  -- 模式 3：减号或点号指定分配 N-A 或 N.A 或 N-A-B...
  if expr:find("[%-%./]") then
    -- 如果带有未完成的符号（如仅末尾是 - 或 .），支持即时预览
    local clean_expr = expr:gsub("[%-%./]+$", "")
    local parts = {}
    for num in clean_expr:gmatch("%d+") do
      table.insert(parts, tonumber(num))
    end

    if #parts >= 2 then
      local N = parts[1]
      local n_cn = to_upper_num(N)
      local prefix = "壹式" .. n_cn .. "份，"

      local allocated = {}
      local sum = 0
      for i = 2, #parts do
        local cnt = parts[i]
        sum = sum + cnt
        table.insert(allocated, cnt)
      end

      if sum > N then
        yield(Candidate("fenshu", seg.start, seg._end, "〔分配份数(" .. sum .. ")已超出总份数(" .. N .. ")〕", "〔超出总份数〕"))
        return
      end

      -- 如果尚未分完，自动将剩余份数推定给下一方
      if sum < N then
        local rem = N - sum
        table.insert(allocated, rem)
      end

      local items_zhi = {}
      for i, cnt in ipairs(allocated) do
        local p = party_names[i] or ("第" .. i .. "方")
        local cnt_cn = to_upper_num(cnt)
        table.insert(items_zhi, p .. "执" .. cnt_cn .. "份")
      end

      local clause_zhi = table.concat(items_zhi, "，")

      yield(Candidate("fenshu", seg.start, seg._end, prefix .. clause_zhi, "〔规范执〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "本合同" .. prefix .. clause_zhi .. "，具有同等法律效力。", "〔合同条款〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "壹式" .. n_cn .. "份", "〔纯份数〕"))
      return
    end
  end

  -- 模式 1：纯数字总额 N（默认双方）
  local pure_num = expr:match("^(%d+)$")
  if pure_num then
    local N = tonumber(pure_num)
    if not N or N <= 0 then return end

    local n_cn = to_upper_num(N)
    local prefix = "壹式" .. n_cn .. "份，"

    if N == 1 then
      yield(Candidate("fenshu", seg.start, seg._end, "壹式" .. n_cn .. "份，由甲方执" .. n_cn .. "份", "〔独执〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "本合同壹式" .. n_cn .. "份，由甲方执" .. n_cn .. "份，具有同等法律效力。", "〔合同条款〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "壹式" .. n_cn .. "份", "〔纯份数〕"))
      return
    end

    if N % 2 == 0 then
      -- 偶数均分（如 4 -> 2 份）
      local half = N / 2
      local half_cn = to_upper_num(half)

      yield(Candidate("fenshu", seg.start, seg._end, prefix .. "甲乙双方各执" .. half_cn .. "份", "〔双方执〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "本合同" .. prefix .. "甲乙双方各执" .. half_cn .. "份，具有同等法律效力。", "〔合同条款〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "壹式" .. n_cn .. "份", "〔纯份数〕"))
    else
      -- 奇数（如 5 -> 甲3乙2 或 甲2乙3）
      local p1 = math.ceil(N / 2)
      local p2 = math.floor(N / 2)
      local p1_cn = to_upper_num(p1)
      local p2_cn = to_upper_num(p2)

      yield(Candidate("fenshu", seg.start, seg._end, prefix .. "甲方执" .. p1_cn .. "份，乙方执" .. p2_cn .. "份", "〔甲多乙少〕"))
      yield(Candidate("fenshu", seg.start, seg._end, prefix .. "甲方执" .. p2_cn .. "份，乙方执" .. p1_cn .. "份", "〔甲少乙多〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "本合同" .. prefix .. "甲方执" .. p1_cn .. "份，乙方执" .. p2_cn .. "份，具有同等法律效力。", "〔合同条款〕"))
      yield(Candidate("fenshu", seg.start, seg._end, "壹式" .. n_cn .. "份", "〔纯份数〕"))
    end
    return
  end
end

return translator
