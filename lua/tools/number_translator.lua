-- 来源 https://github.com/yanhuacuo/98wubi-tables > http://98wb.ysepan.com/
-- 数字、金额大写 (任意大写字母引导+数字)

local function splitNumPart(str)
	local part = {}
	part.int, part.dot, part.dec = string.match(str, "^(%d*)(%.?)(%d*)")
	return part
end

local function GetPreciseDecimal(nNum, n)
	if type(nNum) ~= "number" then nNum =tonumber(nNum) end
	n = n or 0;
	n = math.floor(n)
	if n < 0 then n = 0 end
	local nDecimal = 10 ^ n
	local nTemp = math.floor(nNum * nDecimal);
	local nRet = nTemp / nDecimal;
	return nRet;
end

local function decimal_func(str, posMap, valMap)
	local dec
	posMap = posMap or {[1]="角"; [2]="分"; [3]="厘"; [4]="毫"}
	valMap = valMap or {[0]="零"; "壹"; "贰"; "叁" ;"肆"; "伍"; "陆"; "柒"; "捌"; "玖"}
	if #str>4 then dec = string.sub(tostring(str), 1, 4) else dec =tostring(str) end
	dec = string.gsub(dec, "0+$", "")
	
	if dec == "" then return "整" end

	local result = ""
	for pos =1, #dec do
		local val = tonumber(string.sub(dec, pos, pos))
		if val~=0 then result = result .. valMap[val] .. posMap[pos] else result = result .. valMap[val] end
	end
	result=result:gsub(valMap[0]..valMap[0] ,valMap[0])
	return result:gsub(valMap[0]..valMap[0] ,valMap[0])
end

-- 把数字串按千分位四位数分割，进行转换为中文
local function formatNum(num,t)
	local digitUnit,wordFigure
	local result=""
	num=tostring(num)
	if tonumber(t) < 1 then digitUnit = {"", "十", "百","千"} else digitUnit = {"","拾","佰","仟"} end
	if tonumber(t) <1 then
		wordFigure = {"〇","一","二","三","四","五","六","七","八","九"}
	else wordFigure = {"零","壹","贰","叁","肆","伍","陆","柒","捌","玖"} end
	if string.len(num)>4 or tonumber(num)==0 then return wordFigure[1] end
	local lens=string.len(num)
	for i=1,lens do
		local n=wordFigure[tonumber(string.sub(num,-i,-i))+1]
		if n~=wordFigure[1] then result=n .. digitUnit[i] .. result else result=n .. result end
	end
	result=result:gsub(wordFigure[1]..wordFigure[1] ,wordFigure[1])
	result=result:gsub(wordFigure[1].."$","") result=result:gsub(wordFigure[1].."$","")

	return result
end

-- 数值转换为中文
function number2cnChar(num,flag,digitUnit,wordFigure)    --flag=0中文小写反之为大写
	local st,result
	num=tostring(num) result=""
	local num1,num2=math.modf(num)
	if tonumber(num2)==0 then
		if tonumber(flag) < 1 then
			digitUnit = digitUnit or {[1]="万";[2]="亿"}  wordFigure = wordFigure or {[1]="〇"; [2]="一"; [3]="十"; [4]="元"}
		else
			digitUnit = digitUnit or {[1]="万";[2]="亿"}  wordFigure = wordFigure or {[1]="零"; [2]="壹"; [3]="拾"; [4]="元"}
		end
		local lens=string.len(num1)
		if lens<5 then result=formatNum(num1,flag) elseif lens<9 then result=formatNum(string.sub(num1,1,-5),flag) .. digitUnit[1].. formatNum(string.sub(num1,-4,-1),flag)
		elseif lens<13 then result=formatNum(string.sub(num1,1,-9),flag) .. digitUnit[2] .. formatNum(string.sub(num1,-8,-5),flag) .. digitUnit[1] .. formatNum(string.sub(num1,-4,-1),flag) else result="" end
		result=result:gsub("^" .. wordFigure[1],"") result=result:gsub(wordFigure[1] .. digitUnit[1],"") result=result:gsub(wordFigure[1] .. digitUnit[2],"")
		result=result:gsub(wordFigure[1] .. wordFigure[1],wordFigure[1]) result=result:gsub(wordFigure[1] .. "$","")
		if lens>4 then result=result:gsub("^"..wordFigure[2].. wordFigure[3],wordFigure[3]) end
		if result~="" then result=result .. wordFigure[4] else result="数值超限！" end
	else return "数值超限！" end

	return result
end

local function number2zh(num,t)
	local result,wordFigure
	result="" 
	if tonumber(t) <1 then
		wordFigure = {"〇","一","二","三","四","五","六","七","八","九"}
	else wordFigure = {"零","壹","贰","叁","肆","伍","陆","柒","捌","玖"} end
	if tostring(num)==nil then return "" end
	for pos=1,string.len(num) do
		result=result..wordFigure[tonumber(string.sub(num, pos, pos)+1)]
	end
	result=result:gsub(wordFigure[1] .. wordFigure[1],wordFigure[1])
	return result:gsub(wordFigure[1] .. wordFigure[1],wordFigure[1])
end

-- 将不超过 16 位的非负整数转换为中文数词，供法条序号使用。
-- 按四位一组处理，可正确补出「一万零一」中的「零」。
local function integer2cn(num, uppercase)
	local digits = uppercase
		and {"零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"}
		or {"零", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
	local small_units = uppercase and {"", "拾", "佰", "仟"} or {"", "十", "百", "千"}
	local large_units = {"", "万", "亿", "兆"}

	num = tostring(num):gsub("^0+", "")
	if num == "" then return "零" end
	if #num > 16 then return nil end

	local function section2cn(section)
		local value = tonumber(section)
		local result = ""
		local position = 1
		local pending_zero = false

		while value > 0 do
			local digit = value % 10
			if digit == 0 then
				if result ~= "" then pending_zero = true end
			else
				local prefix = digits[digit + 1] .. small_units[position]
				if pending_zero then prefix = prefix .. "零" end
				result = prefix .. result
				pending_zero = false
			end
			value = math.floor(value / 10)
			position = position + 1
		end

		return result
	end

	local sections = {}
	local cursor = #num
	while cursor > 0 do
		local first = math.max(1, cursor - 3)
		table.insert(sections, 1, num:sub(first, cursor))
		cursor = first - 1
	end

	local result = ""
	local pending_zero = false
	for index, section in ipairs(sections) do
		local value = tonumber(section)
		if value == 0 then
			if result ~= "" then pending_zero = true end
		else
			if result ~= "" and (pending_zero or value < 1000) then
				result = result .. "零"
			end
			result = result .. section2cn(section) .. large_units[#sections - index + 1]
			pending_zero = false
		end
	end

	-- 10～19 通常写作「十X」，而不是「一十X」。
	if uppercase then return result end
	return result:gsub("^一十", "十")
end

local function number_translatorFunc(num)
	local numberPart=splitNumPart(num)
	local result={}
	if numberPart.dot~="" then
		table.insert(result,{number2cnChar(numberPart.int,0,{"万", "亿"},{"〇","一","十","点"})..number2zh(numberPart.dec,0),"〔数字小写〕"})
		table.insert(result,{number2cnChar(numberPart.int,1,{"萬", "億"},{"〇","一","十","点"})..number2zh(numberPart.dec,1),"〔数字大写〕"})
	else
		table.insert(result,{number2cnChar(numberPart.int,0,{"万", "亿"},{"〇","一","十",""}),"〔数字小写〕"})
		table.insert(result,{number2cnChar(numberPart.int,1,{"萬", "億"},{"零","壹","拾",""}),"〔数字大写〕"})
	end
	table.insert(result,{number2cnChar(numberPart.int,0)..decimal_func(numberPart.dec,{[1]="角"; [2]="分"; [3]="厘"; [4]="毫"},{[0]="〇"; "一"; "二"; "三" ;"四"; "五"; "六"; "七"; "八"; "九"}),"〔金额小写〕"})
	table.insert(result,{number2cnChar(numberPart.int,1)..decimal_func(numberPart.dec,{[1]="角"; [2]="分"; [3]="厘"; [4]="毫"},{[0]="零"; "壹"; "贰"; "叁" ;"肆"; "伍"; "陆"; "柒"; "捌"; "玖"}),"〔金额大写〕"})
	return result
end

-- D/d 生成法条序号，R/r 生成数字及金额候选。
local function number_translator(input, seg, env)
	local article_code = input:match("^[Dd](.+)$")
	if article_code then
		local article_number, paragraph_number, item_number, unit_name
		local unit_names = {
			t = "条",
			v = "章",
			z = "章",
			zh = "章",
			j = "节",
			k = "款",
			x = "项",
			y = "页",
		}

		local unit_number, unit_code = article_code:match("^(%d+)(%a+)$")
		if unit_number and unit_names[unit_code] then
			article_number = unit_number
			unit_name = unit_names[unit_code]
		end

		if not article_number then
			article_number, paragraph_number, item_number = article_code:match("^(%d+)%.(%d+)%.(%d+)$")
		end
		if not article_number then
			article_number, item_number = article_code:match("^(%d+)%.%.(%d+)$")
		end
		if not article_number then
			article_number, paragraph_number = article_code:match("^(%d+)%.(%d+)$")
		end
		if not article_number then
			article_number = article_code:match("^(%d+)$")
		end

		if article_number then
			local function normalized(number)
				if not number then return nil end
				local result = number:gsub("^0+", "")
				return result == "" and "0" or result
			end

			local chinese_article = integer2cn(article_number)
			local uppercase_chinese_article = integer2cn(article_number, true)
			local chinese_paragraph = paragraph_number and integer2cn(paragraph_number) or nil
			local chinese_item = item_number and integer2cn(item_number) or nil
			if chinese_article
				and (not paragraph_number or chinese_paragraph)
				and (not item_number or chinese_item) then
				local base_unit = unit_name or "条"
				local chinese_text = "第" .. chinese_article .. base_unit
				local arabic_text = "第" .. normalized(article_number) .. base_unit
				if paragraph_number then
					chinese_text = chinese_text .. "第" .. chinese_paragraph .. "款"
					arabic_text = arabic_text .. "第" .. normalized(paragraph_number) .. "款"
				end
				if item_number then
					chinese_text = chinese_text .. "第" .. chinese_item .. "项"
					arabic_text = arabic_text .. "第" .. normalized(item_number) .. "项"
				end

				yield(Candidate("law_article", seg.start, seg._end, chinese_text, "〔法条序号〕"))
				yield(Candidate("law_article", seg.start, seg._end, arabic_text, "〔法条序号〕"))
				if not unit_name and not paragraph_number and not item_number then
					yield(Candidate("law_article", seg.start, seg._end, "第" .. chinese_article, "〔汉字序号〕"))
				end
			end
		end
		return
	end

	-- 临时取消数字金额大写功能按键，之后处理
	-- local str = input:match("^[Rr](%d+%.?%d*)$")
	local str = nil
    local numberPart
    if str then
        numberPart = number_translatorFunc(str)
        if str and #str > 0 and #numberPart > 0 then
            for i = 1, #numberPart do
                yield(Candidate(input, seg.start, seg._end, numberPart[i][1], numberPart[i][2]))
            end
        end
    end
end

-- print(#number_translatorFunc(3355.433))
return number_translator
