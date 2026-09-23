--[[
  direct_aux.lua
  小鹤双拼直接辅助码：查基础词组、首字筛选、消费完整编码
  
  功能特性：
  1. 正常输入小鹤双拼词组时，无需按额外触发键，直接继续输入字母作为辅助码。
  2. 默认匹配词组中第一个汉字的辅助码（word_match: first）。
  3. 预留扩展匹配策略：last（末字）、first_last（首末字）、any（任意字）。
  4. 支持候选排序模式：promote（匹配项置顶，未匹配项保留在后）与 filter（只保留匹配项）。
  5. 单独查询去掉辅码后的双拼词组，只有完整词组命中辅码时才触发；
     若无任何匹配，完全回退为正常双拼输入，不吞键、不阻断后续输入。
  6. 复用现有小鹤辅助码表（flypy_full.txt），无需额外维护码表。
  7. 筛选词消费「双拼 + 辅码」全部输入，原始组句候选保留原来的消费范围。
--]]

local DirectAux = {}

-- 全局辅码缓存（跨实例与各会话共享）
DirectAux.cache = DirectAux.cache or setmetatable({}, { __mode = "v" })

--------------------------------------------------------------------------------
-- 1. 读取辅码文件
--------------------------------------------------------------------------------
function DirectAux.read_aux_dict(dict_name)
    dict_name = dict_name or "flypy_full"
    if DirectAux.cache[dict_name] then
        return DirectAux.cache[dict_name]
    end

    local user_dir = rime_api and rime_api.get_user_data_dir and rime_api.get_user_data_dir() or ""
    local dict_path = user_dir .. "/lua/aux_code/" .. dict_name .. ".txt"

    local file = io.open(dict_path, "r")
    if not file then
        -- 尝试相对路径或备用路径
        file = io.open("lua/aux_code/" .. dict_name .. ".txt", "r")
    end

    if not file then
        return {}
    end

    local aux_codes = {}
    for line in file:lines() do
        local clean_line = line:match("[^\r\n]+")
        if clean_line then
            local key, value = clean_line:match("([^=]+)=(.+)")
            if key and value then
                if aux_codes[key] then
                    aux_codes[key] = aux_codes[key] .. " " .. value
                else
                    aux_codes[key] = value
                end
            end
        end
    end
    file:close()

    DirectAux.cache[dict_name] = aux_codes
    return aux_codes
end

--------------------------------------------------------------------------------
-- 2. 汉字辅码索引（按字懒加载）
--------------------------------------------------------------------------------
local function get_char_aux_index(env, char)
    local cached = env.aux_index[char]
    if cached ~= nil then
        return cached or nil
    end

    local codes = env.aux_code[char]
    if not codes then
        env.aux_index[char] = false
        return nil
    end

    local entry = { k1 = {}, k12 = {}, full = {} }
    for code in codes:gmatch("%S+") do
        if #code >= 1 then
            entry.k1[code:sub(1, 1)] = true
        end
        if #code >= 2 then
            entry.k12[code:sub(1, 2)] = true
        end
        entry.full[code] = true
    end

    env.aux_index[char] = entry
    return entry
end

--------------------------------------------------------------------------------
-- 3. 从候选词提取目标汉字
--    排除 Emoji、标点、特殊符号，仅保留常用汉字
--------------------------------------------------------------------------------
local function is_cjk(cp)
    return (cp >= 0x3400 and cp <= 0x4DBF) or
           (cp >= 0x4E00 and cp <= 0x9FFF) or
           (cp >= 0xF900 and cp <= 0xFAFF) or
           (cp >= 0x20000 and cp <= 0x2EBEF) or
           (cp >= 0x30000 and cp <= 0x323AF)
end

local function get_aux_targets(text, mode)
    local chars = {}
    for _, cp in utf8.codes(text) do
        if is_cjk(cp) then
            table.insert(chars, utf8.char(cp))
        end
    end

    local len = #chars
    -- 条件 2：候选至少包含 2 个汉字（本阶段仅处理词组，单字放行）
    if len < 2 then
        return nil
    end

    if mode == "first" then
        return { chars[1] }
    elseif mode == "last" then
        return { chars[len] }
    elseif mode == "first_last" then
        return { chars[1], chars[len] }
    elseif mode == "any" then
        return chars
    else
        return { chars[1] }
    end
end

--------------------------------------------------------------------------------
-- 4. 辅助码匹配判断
--------------------------------------------------------------------------------
local function candidate_matches_aux(env, target_chars, aux_str)
    if not target_chars or #target_chars == 0 or not aux_str or #aux_str == 0 then
        return false
    end

    local mode = env.word_match
    local match_mode = env.match_mode

    -- 首末字组合模式扩展支持
    if mode == "first_last" then
        if #aux_str == 1 then
            local e1 = get_char_aux_index(env, target_chars[1])
            return e1 and (e1.k1[aux_str] or false) or false
        else
            local e1 = get_char_aux_index(env, target_chars[1])
            local e2 = get_char_aux_index(env, target_chars[2])
            local c1 = aux_str:sub(1, 1)
            local c2 = aux_str:sub(2, 2)
            return (e1 and e1.k1[c1] or false) and (e2 and e2.k1[c2] or false)
        end
    end

    -- first / last / any 模式统一遍历目标汉字
    for _, ch in ipairs(target_chars) do
        local entry = get_char_aux_index(env, ch)
        if entry then
            if match_mode == "exact" then
                if entry.full[aux_str] then
                    return true
                end
            else
                -- prefix 模式
                if #aux_str == 1 and entry.k1[aux_str] then
                    return true
                elseif #aux_str >= 2 and entry.k12[aux_str:sub(1, 2)] then
                    return true
                end
            end
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- 5. 初始化
--------------------------------------------------------------------------------
function DirectAux.init(env)
    local config = env.engine.schema.config

    -- 读取 direct_aux 配置
    env.enabled = config:get_bool("direct_aux/enabled")
    if env.enabled == nil then
        env.enabled = true
    end

    env.word_match = config:get_string("direct_aux/word_match") or "first"
    env.max_aux_length = config:get_int("direct_aux/max_aux_length") or 2
    env.match_mode = config:get_string("direct_aux/match_mode") or "prefix"
    env.candidate_mode = config:get_string("direct_aux/candidate_mode") or "promote"
    env.show_aux_comment = config:get_bool("direct_aux/show_aux_comment") or false
    env.max_candidates = math.max(1, config:get_int("direct_aux/max_candidates") or 256)

    -- 辅码数据源（默认小鹤音形 full 码表）
    local dict_name = config:get_string("direct_aux/aux_dict") or "flypy_full"
    env.aux_code = DirectAux.read_aux_dict(dict_name)
    env.aux_index = {}
    env.translators = {}
    if not env.enabled then return end

    -- 只调用原生词典翻译器，不递归运行整条带 direct_aux 的过滤链。
    local translators = config:get_list("direct_aux/translators")
    local names = { "script_translator" }
    if translators then
        names = {}
        for i = 0, translators.size - 1 do
            names[#names + 1] = translators:get_value_at(i).value
        end
    end
    for _, name in ipairs(names) do
        local class, namespace = name:match("^([^@]+)@(.+)$")
        local translator = Component.Translator(env.engine, namespace or "translator", class or name)
        if translator then
            -- 主方案原有翻译器负责学习；查询实例不再重复记词频。
            translator:set_memorize_callback(function() return false end)
            env.translators[#env.translators + 1] = translator
        end
    end
end

-- 完整双拼词组：一字两码，排除补全词、单字和混合符号候选。
local function is_complete_word(cand, segment, syllables)
    if cand.start ~= segment.start or cand._end ~= segment._end then
        return false
    end
    local count = 0
    for _, cp in utf8.codes(cand.text) do
        if not is_cjk(cp) then return false end
        count = count + 1
    end
    return count == syllables
end

local function query_matches(env, segment, base_input, aux_input)
    local base_segment = Segment(segment.start, segment.start + #base_input)
    base_segment.tags = Set({ "abc" })
    local matches = {}
    for _, translator in ipairs(env.translators) do
        local translation = translator:query(base_input, base_segment)
        if translation then
            local checked = 0
            for cand in translation:iter() do
                checked = checked + 1
                if is_complete_word(cand, base_segment, #base_input / 2)
                    and candidate_matches_aux(env, get_aux_targets(cand.text, env.word_match), aux_input) then
                    matches[#matches + 1] = { candidate = cand, order = #matches + 1 }
                end
                if checked >= env.max_candidates then break end
            end
        end
    end
    -- 主词库与个人词库合并时保留原生词频；相同权重保持稳定顺序。
    table.sort(matches, function(a, b)
        if a.candidate.quality == b.candidate.quality then return a.order < b.order end
        return a.candidate.quality > b.candidate.quality
    end)
    return matches
end

function DirectAux.func(input, env)
    local context = env.engine.context
    local segment = context.composition:back()
    local raw_input = context.input or ""
    local eligible = env.enabled and segment and segment:has_tag("abc")
        and segment._end == #raw_input and context.caret_pos == #raw_input
        and (context:get_property("tab_mode") or "") == ""
    local code = eligible and raw_input:sub(segment.start + 1, segment._end) or ""
    local matches, aux_input = {}, nil

    if #code >= 5 and code:match("^[a-z]+$") then
        for aux_len = 1, math.min(env.max_aux_length, 2) do
            local base_len = #code - aux_len
            if base_len >= 4 and base_len % 2 == 0 then
                aux_input = code:sub(base_len + 1)
                matches = query_matches(env, segment, code:sub(1, base_len), aux_input)
                if #matches > 0 then break end
            end
        end
    end

    local seen = {}
    for _, item in ipairs(matches) do
        local cand = item.candidate
        if not seen[cand.text] then
            seen[cand.text] = true
            -- 查询返回的是独立的基础词组候选。扩大消费范围，不改词典音节编码，
            -- 让空格、数字、鼠标选词都一次上屏，同时继续由原生用户词典学习。
            cand._end = segment._end
            if env.show_aux_comment then
                cand.comment = (cand.comment or "") .. " [" .. aux_input .. "]"
            end
            yield(cand)
        end
    end

    -- 无匹配时完整回退；有匹配时将原始组句流接在筛选词之后。
    -- 去掉同文的短范围候选，避免再选到只消费双拼、残留辅码的版本。
    if #matches == 0 or env.candidate_mode == "promote" then
        for cand in input:iter() do
            if not seen[cand.text] then yield(cand) end
        end
    end
end

function DirectAux.fini(env)
    env.translators = nil
    env.aux_index = nil
    env.aux_code = nil
end

return DirectAux
