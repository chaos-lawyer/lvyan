--[[
  name_translator.lua
  人名模式专用 Translator（基于 120W 现代中文语料强化方案）：
  Level 1: 独立用户学习词典 (name_user_dict_v2.txt)
  Level 2: 语料完整姓名 (full_name.dict.yaml)
  Level 3: 单姓 + 观察双字名搭配 (surname + given_name_2，带同音姓氏公平配额)
  Level 4: 单姓 + 首末字统计平滑回退 (surname + given_name_first + given_name_last + 叠字)
  Level 5: 复姓动态组合 (compound_surname + given_name_1/2)
  Level 6: 两字姓名 (单姓 + 观察单字名 surname + given_name_1)
  Level 7: 单键姓氏 (2码)
--]]

local name_utils = require("name_utils")
local user_initials = nil
pcall(function() user_initials = require("user_initials_history") end)

local M = {}

function M.init(env)
  env.name_tr = Component.Translator(env.engine, "name_corpus", "script_translator")
  if env.name_tr then
    env.name_tr:set_memorize_callback(function() return false end)
  end

  env.last_code = ""
  local context = env.engine.context

  env.commit_conn = context.commit_notifier:connect(function(ctx)
    local text = ctx.get_commit_text and ctx:get_commit_text() or ""
    local in_name_mode = ctx:get_option("name_mode")
    if text ~= "" and env.last_code ~= "" then
      local count = 0
      for _, cp in utf8.codes(text) do
        count = count + 1
      end

      -- 提取纯双拼基准码 (去除触发键 ; 及辅码后缀，按字数截取对应双拼长度)
      local base = env.last_code:gsub(";.*$", "")
      if #base >= count * 2 then
        base = base:sub(1, count * 2)
      end

      local initials = ""
      for i = 1, #base, 2 do
        initials = initials .. base:sub(i, i)
      end

      if in_name_mode then
        if count >= 2 and count <= 4 then
          name_utils.record_commit(base, text)
          -- 自动将人名首拼同步至双拼自造词首拼自学习系统
          if initials ~= "" and user_initials and user_initials.record then
            user_initials.record(initials, text)
          end
        end
      else
        -- 普通模式下：若上屏的是已学习的人名，累加使用频次并更新时间
        if env.last_code:sub(1, 1) == "\\" then
          local user_dict = name_utils.load_user_dict()
          for code, entries in pairs(user_dict) do
            for _, e in ipairs(entries) do
              if e.text == text then
                name_utils.record_commit(code, text)
                local inits = ""
                for i = 1, #code, 2 do
                  inits = inits .. code:sub(i, i)
                end
                if inits ~= "" and user_initials and user_initials.record then
                  user_initials.record(inits, text)
                end
                break
              end
            end
          end
        else
          local user_dict = name_utils.load_user_dict()
          local histories = user_dict[base]
          if histories then
            for _, e in ipairs(histories) do
              if e.text == text then
                name_utils.record_commit(base, text)
                if initials ~= "" and user_initials and user_initials.record then
                  user_initials.record(initials, text)
                end
                break
              end
            end
          end
        end
      end
    end
    -- 一次性人名模式：上屏后立即自动切换回正常模式
    if in_name_mode then
      ctx:set_option("name_mode", false)
    end
  end)

  env.update_conn = context.update_notifier:connect(function(ctx)
    -- 一次性人名模式：若组合被取消或退格清空（非 composing 状态），自动退出人名模式
    if not ctx:is_composing() and ctx:get_option("name_mode") then
      ctx:set_option("name_mode", false)
    end
  end)
end

function M.fini(env)
  if env.commit_conn then
    env.commit_conn:disconnect()
    env.commit_conn = nil
  end
  if env.update_conn then
    env.update_conn:disconnect()
    env.update_conn = nil
  end
  if env.name_tr and env.name_tr.disconnect then
    env.name_tr:disconnect()
    env.name_tr = nil
  end
end

local function count_chars(str)
  local c = 0
  for _, cp in utf8.codes(str) do
    c = c + 1
  end
  return c
end

local function make_seg(start_pos, end_pos)
  local s = Segment(start_pos, end_pos)
  s.tags = Set({ "abc" })
  return s
end

-- 获取单字候选列表及名字首/末字支持度
local function collect_char_candidates(trans, is_first)
  local list = {}
  local seen = {}
  if trans then
    for cand in trans:iter() do
      if count_chars(cand.text) == 1 and not seen[cand.text] then
        seen[cand.text] = true
        local w = is_first and name_utils.get_first_char_weight(cand.text)
                           or name_utils.get_last_char_weight(cand.text)
        if w > 0 then
          table.insert(list, { text = cand.text, weight = w })
        end
        if #list >= 30 then break end
      end
    end
  end
  return list
end

local function get_interpretations(input)
  local interps = {}
  -- 1. 触发辅码模式 (包含分号 ;)
  local base, aux = input:match("^([a-z]+);([a-z]*)$")
  if base then
    if #base >= 2 and #base % 2 == 0 then
      table.insert(interps, {
        base_code = base,
        aux_code = (aux ~= "" and aux:lower() or nil),
        is_explicit_aux = (aux ~= ""),
      })
    end
    return interps
  end

  -- 2. 纯字母输入：
  local len = #input
  if len % 2 == 1 then
    -- 奇数长度：必然为 (len - 1) 双拼 + 1 位直接辅码 (例如 lue -> lu + e; whjykda -> whjykd + a)
    if len >= 3 then
      table.insert(interps, {
        base_code = input:sub(1, len - 1),
        aux_code = input:sub(len):lower(),
        is_explicit_aux = true,
      })
    end
  else
    -- 偶数长度：
    -- 优先尝试切分末尾 2 位辅助码 (例如 luej -> lu + ej; luwwrw -> luww + rw; whjykdej -> whjykd + ej)
    if len >= 4 then
      table.insert(interps, {
        base_code = input:sub(1, len - 2),
        aux_code = input:sub(len - 1, len):lower(),
        is_explicit_aux = true,
      })
    end
    -- 同时作为纯双拼候选 (例如 luww -> 陆伟, whjykd -> 王俊凯)
    table.insert(interps, {
      base_code = input,
      aux_code = nil,
      is_explicit_aux = false,
    })
  end
  return interps
end

local function translate_interpretation(interp, seg, env, yielded)
  local base_code = interp.base_code
  local aux_code = interp.aux_code

  -- Level 1: 独立用户学习人名 (name_user_dict_v2) 绝对置顶
  local user_dict = name_utils.load_user_dict()
  local histories = user_dict[base_code] or {}
  for _, e in ipairs(histories) do
    local matched, pos = name_utils.match_aux(e.text, aux_code)
    if matched and not yielded[e.text] then
      local cand = Candidate("name", seg.start, seg._end, e.text, "〔人名*〕")
      cand.quality = 1200 + e.count * 10
      yield(cand)
      yielded[e.text] = true
    end
  end

  if not env.name_tr then return end

  -- Level 2: 语料库完整姓名匹配 (full_name)
  local base_seg = make_seg(seg.start, seg.start + #base_code)
  local trans = env.name_tr:query(base_code, base_seg)
  local expected_chars = math.floor(#base_code / 2)

  local level2_cands = {}
  if trans then
    for cand in trans:iter() do
      if count_chars(cand.text) == expected_chars then
        local matched, pos = name_utils.match_aux(cand.text, aux_code)
        if matched and not yielded[cand.text] then
          local bonus = (cand.quality or 0) * 0.1
          if aux_code and pos then bonus = bonus + 300 end
          table.insert(level2_cands, {
            text = cand.text,
            quality = 600 + bonus,
          })
        end
      end
    end
  end

  table.sort(level2_cands, function(a, b) return a.quality > b.quality end)
  for i = 1, math.min(60, #level2_cands) do
    local item = level2_cands[i]
    if not yielded[item.text] then
      local c = Candidate("name", seg.start, seg._end, item.text, "〔人名〕")
      c.quality = item.quality
      yield(c)
      yielded[item.text] = true
    end
  end

  -- Level 3/4/5a: 6 码输入 (三字姓名: 单姓 + 双字名 或 复姓 + 单字名)
  if #base_code == 6 then
    local s_code = base_code:sub(1, 2)
    local g_code = base_code:sub(3, 6)

    local s_trans = env.name_tr:query(s_code, make_seg(seg.start, seg.start + 2))
    local g_trans = env.name_tr:query(g_code, make_seg(seg.start + 2, seg.start + 6))

    local s_list = {}
    if s_trans then
      for cand in s_trans:iter() do
        if count_chars(cand.text) == 1 and name_utils.is_surname(cand.text) then
          table.insert(s_list, { text = cand.text, weight = name_utils.get_surname_weight(cand.text) })
        end
      end
    end

    local g2_list = {}
    if g_trans then
      for cand in g_trans:iter() do
        if count_chars(cand.text) == 2 and name_utils.is_given_name_2(cand.text) then
          table.insert(g2_list, { text = cand.text, weight = name_utils.get_given_name_2_weight(cand.text) })
        end
      end
    end

    -- Level 3: 单姓 + 双字名搭配 (同音姓氏公平配额)
    local level3_cands = {}
    for _, s in ipairs(s_list) do
      local s_yield_count = 0
      for _, g in ipairs(g2_list) do
        local full = s.text .. g.text
        local matched, pos = name_utils.match_aux(full, aux_code)
        if matched and not yielded[full] then
          local score = 380 + s.weight * 0.03 + g.weight * 0.05
          local g_first = full:sub(4, 6)
          local g_second = full:sub(7, 9)
          if g_first == g_second then score = score + 40 end
          if aux_code and pos then score = score + 300 end

          table.insert(level3_cands, { text = full, quality = score, surname = s.text })
          s_yield_count = s_yield_count + 1
          if s_yield_count >= 12 then break end
        end
      end
    end

    table.sort(level3_cands, function(a, b) return a.quality > b.quality end)
    for i = 1, math.min(50, #level3_cands) do
      local item = level3_cands[i]
      if not yielded[item.text] then
        local c = Candidate("name", seg.start, seg._end, item.text, "〔人名〕")
        c.quality = item.quality
        yield(c)
        yielded[item.text] = true
      end
    end

    -- Level 4: 单姓 + 名字首末字有限统计组合 (平滑回退，未见搭配)
    local first_code = base_code:sub(3, 4)
    local last_code = base_code:sub(5, 6)
    local first_chars = collect_char_candidates(
      env.name_tr:query(first_code, make_seg(seg.start + 2, seg.start + 4)), true)
    local last_chars = collect_char_candidates(
      env.name_tr:query(last_code, make_seg(seg.start + 4, seg.start + 6)), false)

    local level4_cands = {}
    for _, s in ipairs(s_list) do
      local s_combo_count = 0
      for _, c1 in ipairs(first_chars) do
        for _, c2 in ipairs(last_chars) do
          local full = s.text .. c1.text .. c2.text
          local matched, pos = name_utils.match_aux(full, aux_code)
          if matched and not yielded[full] then
            local score = 200 + s.weight * 0.02 + c1.weight * 0.03 + c2.weight * 0.03
            if c1.text == c2.text then score = score + 40 end
            if aux_code and pos then score = score + 300 end

            table.insert(level4_cands, { text = full, quality = score })
            s_combo_count = s_combo_count + 1
            if s_combo_count >= 8 then break end
          end
        end
        if s_combo_count >= 8 then break end
      end
    end

    table.sort(level4_cands, function(a, b) return a.quality > b.quality end)
    for i = 1, math.min(30, #level4_cands) do
      local item = level4_cands[i]
      if not yielded[item.text] then
        local c = Candidate("name", seg.start, seg._end, item.text, "〔人名·组合〕")
        c.quality = item.quality
        yield(c)
        yielded[item.text] = true
      end
    end

    -- Level 5a: 复姓 4码 + 单字名 2码 (如 欧阳修)
    local cs_code = base_code:sub(1, 4)
    local sg_code = base_code:sub(5, 6)
    local cs_trans = env.name_tr:query(cs_code, make_seg(seg.start, seg.start + 4))
    local sg_trans = env.name_tr:query(sg_code, make_seg(seg.start + 4, seg.start + 6))

    local cs_list = {}
    if cs_trans then
      for cand in cs_trans:iter() do
        if count_chars(cand.text) == 2 and name_utils.is_compound_surname(cand.text) then
          table.insert(cs_list, { text = cand.text, weight = name_utils.get_compound_surname_weight(cand.text) })
        end
      end
    end

    local sg_list = {}
    if sg_trans then
      for cand in sg_trans:iter() do
        if count_chars(cand.text) == 1 then
          table.insert(sg_list, { text = cand.text, weight = name_utils.get_given_name_1_weight(cand.text) })
        end
      end
    end

    for _, cs in ipairs(cs_list) do
      for _, sg in ipairs(sg_list) do
        local full = cs.text .. sg.text
        local matched, pos = name_utils.match_aux(full, aux_code)
        if matched and not yielded[full] then
          local score = 390 + cs.weight * 0.04 + sg.weight * 0.04
          if aux_code and pos then score = score + 300 end
          local c = Candidate("name", seg.start, seg._end, full, "〔人名〕")
          c.quality = score
          yield(c)
          yielded[full] = true
        end
      end
    end
  end

  -- Level 6: 4 码输入 (两字姓名: 单姓 + 单字名)
  if #base_code == 4 then
    local s_code = base_code:sub(1, 2)
    local g_code = base_code:sub(3, 4)
    local s_trans = env.name_tr:query(s_code, make_seg(seg.start, seg.start + 2))
    local g_trans = env.name_tr:query(g_code, make_seg(seg.start + 2, seg.start + 4))

    local s_list = {}
    if s_trans then
      for cand in s_trans:iter() do
        if count_chars(cand.text) == 1 and name_utils.is_surname(cand.text) then
          table.insert(s_list, { text = cand.text, weight = name_utils.get_surname_weight(cand.text) })
        end
      end
    end

    local g1_list = {}
    if g_trans then
      for cand in g_trans:iter() do
        if count_chars(cand.text) == 1 and name_utils.is_given_name_1(cand.text) then
          table.insert(g1_list, { text = cand.text, weight = name_utils.get_given_name_1_weight(cand.text) })
        end
      end
    end

    local level6_cands = {}
    for _, s in ipairs(s_list) do
      for _, g in ipairs(g1_list) do
        local full = s.text .. g.text
        local matched, pos = name_utils.match_aux(full, aux_code)
        if matched and not yielded[full] then
          local score = 320 + s.weight * 0.04 + g.weight * 0.05
          if aux_code and pos then score = score + 300 end
          table.insert(level6_cands, { text = full, quality = score })
        end
      end
    end

    table.sort(level6_cands, function(a, b) return a.quality > b.quality end)
    for i = 1, math.min(40, #level6_cands) do
      local item = level6_cands[i]
      if not yielded[item.text] then
        local c = Candidate("name", seg.start, seg._end, item.text, "〔人名〕")
        c.quality = item.quality
        yield(c)
        yielded[item.text] = true
      end
    end
  end

  -- Level 5b: 8 码输入 (复姓 + 双字名)
  if #base_code == 8 then
    local cs_code = base_code:sub(1, 4)
    local g2_code = base_code:sub(5, 8)
    local cs_trans = env.name_tr:query(cs_code, make_seg(seg.start, seg.start + 4))
    local g2_trans = env.name_tr:query(g2_code, make_seg(seg.start + 4, seg.start + 8))

    local cs_list = {}
    if cs_trans then
      for cand in cs_trans:iter() do
        if count_chars(cand.text) == 2 and name_utils.is_compound_surname(cand.text) then
          table.insert(cs_list, { text = cand.text, weight = name_utils.get_compound_surname_weight(cand.text) })
        end
      end
    end

    local g2_list = {}
    if g2_trans then
      for cand in g2_trans:iter() do
        if count_chars(cand.text) == 2 and name_utils.is_given_name_2(cand.text) then
          table.insert(g2_list, { text = cand.text, weight = name_utils.get_given_name_2_weight(cand.text) })
        end
      end
    end

    for _, cs in ipairs(cs_list) do
      for _, g2 in ipairs(g2_list) do
        local full = cs.text .. g2.text
        local matched, pos = name_utils.match_aux(full, aux_code)
        if matched and not yielded[full] then
          local score = 420 + cs.weight * 0.04 + g2.weight * 0.05
          if aux_code and pos then score = score + 300 end
          local c = Candidate("name", seg.start, seg._end, full, "〔人名〕")
          c.quality = score
          yield(c)
          yielded[full] = true
        end
      end
    end
  end

  -- Level 7: 2 码输入 (单字姓氏)
  if #base_code == 2 then
    local s_trans = env.name_tr:query(base_code, make_seg(seg.start, seg.start + 2))
    if s_trans then
      local s_cands = {}
      for cand in s_trans:iter() do
        if count_chars(cand.text) == 1 and name_utils.is_surname(cand.text) then
          local matched, pos = name_utils.match_aux(cand.text, aux_code)
          if matched and not yielded[cand.text] then
            local score = 200 + (cand.quality or 0) * 0.1
            if aux_code and pos then score = score + 600 end
            table.insert(s_cands, { text = cand.text, quality = score })
          end
        end
      end
      table.sort(s_cands, function(a, b) return a.quality > b.quality end)
      for _, item in ipairs(s_cands) do
        if not yielded[item.text] then
          local c = Candidate("name", seg.start, seg._end, item.text, "〔姓氏〕")
          c.quality = item.quality
          yield(c)
          yielded[item.text] = true
        end
      end
    end
  end
end

function M.func(input, seg, env)
  local context = env.engine.context
  local in_name_mode = context:get_option("name_mode")

  -- 检查是否为反斜杠引导的首拼输入 (如 \wjk 或 \ww)
  local is_initials_mode = input:sub(1, 1) == "\\"
  if not is_initials_mode and not input:match("^[a-z]+$") and not input:match("^[a-z]+;[a-z]*$") then
    return
  end
  env.last_code = input

  local yielded = {}

  ------------------------------------------------------------------------------
  -- 普通模式下输出已学习人名并动态调频：
  -- 1. 支持普通双拼输入 (如 whjykd -> 王俊凯)
  -- 2. 支持带辅助码输入 (如 whjykd;ej 或 whjykda -> 王俊凯)
  -- 3. 支持首拼模式输入 (如 \wjk 或 \ww -> 王俊凯 / 王伟)
  ------------------------------------------------------------------------------
  if not in_name_mode then
    local user_dict = name_utils.load_user_dict()

    -- 场景 A：首拼引导模式 (以 \ 开头)
    if is_initials_mode then
      local query_initials = input:sub(2):lower()
      if #query_initials >= 2 and #query_initials <= 8 then
        for code, entries in pairs(user_dict) do
          local initials = ""
          for i = 1, #code, 2 do
            initials = initials .. code:sub(i, i)
          end
          if initials == query_initials then
            for _, e in ipairs(entries) do
              if not yielded[e.text] then
                local cand = Candidate("name", seg.start, seg._end, e.text, "〔人名〕")
                cand.quality = 1150 + e.count * 20
                yield(cand)
                yielded[e.text] = true
              end
            end
          end
        end
      end
      return
    end

    -- 场景 B：日常普通双拼输入（含直接辅码与分号辅码）
    local interps = get_interpretations(input)
    for _, interp in ipairs(interps) do
      local histories = user_dict[interp.base_code] or {}
      for _, e in ipairs(histories) do
        local matched, pos = name_utils.match_aux(e.text, interp.aux_code)
        if matched and not yielded[e.text] then
          local cand = Candidate("name", seg.start, seg._end, e.text, "〔人名〕")
          local q
          if e.count <= 1 then
            q = -0.5
          elseif e.count == 2 then
            q = 1.5
          elseif e.count == 3 then
            q = 2.200010
          elseif e.count == 4 then
            q = 2.200030
          else
            q = math.min(10.0, 2.5 + (e.count - 5) * 0.1)
          end
          if interp.aux_code and pos then
            q = q + 10.0
          end
          cand.quality = q
          yield(cand)
          yielded[e.text] = true
        end
      end
    end
    return
  end

  ------------------------------------------------------------------------------
  -- 人名模式：遍历所有合法编码切分（支持直接辅码与分号触发辅码），按分层检索候选
  ------------------------------------------------------------------------------
  local interps = get_interpretations(input)
  for _, interp in ipairs(interps) do
    translate_interpretation(interp, seg, env, yielded)
  end
end

return M
