-- 复制自<万象拼音方案> https://github.com/amzxyz/rime_wanxiang
-- @author: amzxyz
-- @modify: Mintimate
-- 修改内容: ① 兼容纠错

local FLYPY_INITIALS = {
    v = "zh", i = "ch", u = "sh"
}

local function flypy_syllable_to_qp(code)
    if #code == 1 then
        if code == "a" or code == "o" or code == "e" then return code end
        return FLYPY_INITIALS[code] or code
    end
    if #code ~= 2 then return code end

    local c1 = code:sub(1, 1)
    local c2 = code:sub(2, 2)

    -- 零声母
    if c1 == "a" then
        if c2 == "a" then return "a"
        elseif c2 == "d" then return "ai"
        elseif c2 == "j" then return "an"
        elseif c2 == "h" then return "ang"
        elseif c2 == "c" then return "ao"
        elseif c2 == "f" then return "en"
        elseif c2 == "g" then return "eng"
        end
    elseif c1 == "o" then
        if c2 == "o" or c2 == "z" or c2 == "u" then
            return (c2 == "o") and "o" or "ou"
        end
    elseif c1 == "e" then
        if c2 == "e" then return "e"
        elseif c2 == "w" then return "ei"
        elseif c2 == "r" then return "er"
        end
    end

    local sm = FLYPY_INITIALS[c1] or c1
    local ym = nil

    if c2 == "a" or c2 == "e" or c2 == "i" or c2 == "u" then
        ym = c2
    elseif c2 == "o" then
        if sm == "b" or sm == "p" or sm == "m" or sm == "f" then
            ym = "o"
        else
            ym = "uo"
        end
    elseif c2 == "v" then
        if sm == "n" or sm == "l" then
            ym = "ü"
        else
            ym = "ui"
        end
    elseif c2 == "q" then ym = "iu"
    elseif c2 == "w" then ym = "ei"
    elseif c2 == "r" then ym = "uan"
    elseif c2 == "t" then
        if sm == "n" or sm == "l" then ym = "üe"
        elseif sm == "y" then return "yue"
        else ym = "ue" end
    elseif c2 == "y" then ym = "un"
    elseif c2 == "p" then
        if sm == "y" then return "ye" else ym = "ie" end
    elseif c2 == "s" then
        if sm == "j" or sm == "q" or sm == "x" then ym = "iong"
        elseif sm == "y" then return "yong"
        else ym = "ong" end
    elseif c2 == "d" then ym = "ai"
    elseif c2 == "f" then ym = "en"
    elseif c2 == "g" then ym = "eng"
    elseif c2 == "h" then ym = "ang"
    elseif c2 == "j" then ym = "an"
    elseif c2 == "k" then
        if sm == "g" or sm == "k" or sm == "h" or sm == "zh" or sm == "ch" or sm == "sh" then
            ym = "uai"
        elseif sm == "y" then return "ying"
        else ym = "ing" end
    elseif c2 == "l" then
        if sm == "n" or sm == "l" or sm == "j" or sm == "q" or sm == "x" then
            ym = "iang"
        elseif sm == "y" then return "yang"
        else ym = "uang" end
    elseif c2 == "z" then
        if sm == "y" then return "you" else ym = "ou" end
    elseif c2 == "x" then
        if sm == "j" or sm == "q" or sm == "x" then
            ym = "ia"
        elseif sm == "y" then return "ya"
        else ym = "ua" end
    elseif c2 == "c" then
        if sm == "y" then return "yao" else ym = "ao" end
    elseif c2 == "b" then
        if sm == "y" then return "yin" else ym = "in" end
    elseif c2 == "n" then
        if sm == "y" then return "yao" else ym = "iao" end
    elseif c2 == "m" then
        if sm == "y" then return "yan" else ym = "ian" end
    end

    if ym then
        return sm .. ym
    end
    return code
end

local function flypy_to_quanpin_sequence(text)
    if not text or text == "" then return "" end
    local parts = {}
    for chunk in string.gmatch(text, "[^' %-_]+") do
        local len = #chunk
        local i = 1
        while i <= len do
            if i + 1 <= len then
                table.insert(parts, flypy_syllable_to_qp(chunk:sub(i, i + 1)))
                i = i + 2
            else
                table.insert(parts, flypy_syllable_to_qp(chunk:sub(i, i)))
                i = i + 1
            end
        end
    end
    return table.concat(parts, " ")
end

local function modify_preedit_filter(input, env)
    local config = env.engine.schema.config
    local delimiter = config:get_string('speller/delimiter') or " '"

    -- 新增：获取 schema_id
    local schema_id = env.engine.schema.schema_id or ""
    local is_wanxiang_pro = (schema_id == "wanxiang_pro")

    -- 从 YAML 配置读取参数
    local tone_isolate = config:get_bool("speller/tone_isolate")      -- 是否将数字声调从转换后拼音中隔离出来
    local visual_delim = config:get_string("speller/visual_delimiter") or " "  -- 定义转换后的分隔符号

    env.settings = { tone_display = env.engine.context:get_option("tone_display") } or false
    local auto_delimiter = delimiter:sub(1, 1)
    local manual_delimiter = delimiter:sub(2, 2)

    local is_tone_display = env.settings.tone_display
    local context = env.engine.context

    local seg = context.composition:back()
    if seg and seg:has_tag("initials_mode") then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    local is_radical_lookup = seg and seg:has_tag("radical_lookup")
    env.is_special_tag_mode = seg and (
        seg:has_tag("reverse_stroke") or seg:has_tag("correntor")
    ) or false

    for cand in input:iter() do
        local genuine_cand = cand:get_genuine()
        local preedit = genuine_cand.preedit or ""
        local comment = genuine_cand.comment

        local tab_mode = context:get_property("tab_mode") or ""
        if tab_mode == "emoji" or tab_mode == "english" then
            local prefix = context:get_property("tab_mode_prefix") or ""
            if prefix ~= "" and preedit:sub(1, #prefix) == prefix then
                local display = context:get_property("tab_mode_display") or ""
                genuine_cand.preedit = display .. preedit:sub(#prefix + 1)
            end
            yield(genuine_cand)
            goto continue
        end

        if is_radical_lookup then
            -- u 模式（拆字反查）：输入区显示用户输入的拼音（将小鹤双拼转换为全拼）
            genuine_cand.preedit = flypy_to_quanpin_sequence(preedit)
            yield(genuine_cand)
            goto continue
        end

        if env.is_special_tag_mode then
            -- 2025-07-10 Mintimate 使其兼容纠错
            genuine_cand.preedit = comment:gsub("[%[%]]", "")
            yield(genuine_cand)
            goto continue
        end

        if not comment or comment == "" or not is_tone_display then
            yield(cand)
            goto continue
        end

        -- 拆分 preedit
        local input_parts = {}
        local current_segment = ""
        for i = 1, #preedit do
            local char = preedit:sub(i, i)
            if char == auto_delimiter or char == manual_delimiter then
                if #current_segment > 0 then
                    table.insert(input_parts, current_segment)
                    current_segment = ""
                end
                table.insert(input_parts, char)
            else
                current_segment = current_segment .. char
            end
        end
        if #current_segment > 0 then
            table.insert(input_parts, current_segment)
        end

        -- 拆分拼音段（comment）
        local pinyin_segments = {}
        for segment in string.gmatch(comment, "[^" .. auto_delimiter .. manual_delimiter .. "]+") do
            local pinyin = segment:match("^[^;]+")
            if pinyin then
                table.insert(pinyin_segments, pinyin)
            end
        end
        -- 替换逻辑
        local pinyin_index = 1
        for i, part in ipairs(input_parts) do
            if part == auto_delimiter or part == manual_delimiter then
                input_parts[i] = visual_delim
            else
                local body, tone = part:match("(%a+)(%d?)")
                local py = pinyin_segments[pinyin_index]

                if py then
                    if is_wanxiang_pro then
                        input_parts[i] = py
                        pinyin_index = pinyin_index + 1
                    elseif i == #input_parts and #part == 1 then
                        local prefix = py:sub(1, 2)
                        local first_char = part:sub(1,1):lower()
                        if first_char == "s" or first_char == "c" or first_char == "z" then
                            input_parts[i] = part
                        else
                            if prefix == "zh" or prefix == "ch" or prefix == "sh" then
                                input_parts[i] = prefix
                            else
                                input_parts[i] = part
                            end
                        end
                    else
                        if tone_isolate then
                            input_parts[i] = py .. (tone or "")
                        else
                            input_parts[i] = py
                        end
                        pinyin_index = pinyin_index + 1
                    end
                end
            end
        end
        genuine_cand.preedit = table.concat(input_parts)
        yield(genuine_cand)
        ::continue::
    end
end
return modify_preedit_filter
