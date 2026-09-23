--[[
  name_translator.lua
  人名模式专用 Translator：
  Level 1: 独立用户学习词典 (name_user_dict.txt)
  Level 2: 语料完整姓名 (full_name)
  Level 3: 单姓 + 已知双字名动态组合 (surname + given_name_2)
  Level 4: 单姓 + 已知单字名动态组合 (surname + given_name_1)
  Level 5: 复姓动态组合 (compound_surname + given_name_1/2)
  Level 6: 单键姓氏 (2码)
--]]

local name_utils = require("name_utils")

local M = {}

function M.init(env)
  env.name_tr = Component.Translator(env.engine, "name_corpus", "script_translator")
  if env.name_tr then
    env.name_tr:set_memorize_callback(function() return false end)
  end

  env.last_code = ""
  local context = env.engine.context
  env.commit_conn = context.commit_notifier:connect(function(ctx)
    if not ctx:get_option("name_mode") then return end
    local text = ctx.get_commit_text and ctx:get_commit_text() or ""
    if text ~= "" and env.last_code ~= "" then
      local count = 0
      for _, cp in utf8.codes(text) do
        count = count + 1
      end
      if count >= 2 and count <= 4 then
        name_utils.record_commit(env.last_code, text)
      end
    end
    -- 一次性人名模式：上屏后立即自动切换回正常模式
    ctx:set_option("name_mode", false)
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

function M.func(input, seg, env)
  local context = env.engine.context
  if not context:get_option("name_mode") then return end
  if not input:match("^[a-z]+$") then return end

  -- 辅码切分判断 (小鹤双拼：一字2码，辅码1~2码)
  local base_code = input
  local aux_code = nil
  if #input >= 5 and #input % 2 ~= 0 then
    base_code = input:sub(1, #input - 1)
    aux_code = input:sub(#input)
  end

  env.last_code = base_code

  local yielded = {}

  ------------------------------------------------------------------------------
  -- Level 1: 独立用户学习人名
  ------------------------------------------------------------------------------
  local user_dict = name_utils.load_user_dict()
  local histories = user_dict[base_code] or user_dict[input] or {}
  for _, e in ipairs(histories) do
    if (not aux_code or name_utils.match_aux(e.text, aux_code)) and not yielded[e.text] then
      local cand = Candidate("name", seg.start, seg._end, e.text, "〔人名*〕")
      cand.quality = 1000 + e.count * 10
      yield(cand)
      yielded[e.text] = true
    end
  end

  if not env.name_tr then return end

  ------------------------------------------------------------------------------
  -- Level 2: 完整姓名词库匹配
  ------------------------------------------------------------------------------
  local base_seg = make_seg(seg.start, seg.start + #base_code)
  local trans = env.name_tr:query(base_code, base_seg)
  local expected_chars = math.floor(#base_code / 2)

  if trans then
    for cand in trans:iter() do
      if count_chars(cand.text) == expected_chars then
        if (not aux_code or name_utils.match_aux(cand.text, aux_code)) and not yielded[cand.text] then
          local c = Candidate("name", seg.start, seg._end, cand.text, "〔人名〕")
          c.quality = 500 + (cand.quality or 0) * 0.1
          yield(c)
          yielded[cand.text] = true
        end
      end
    end
  end

  ------------------------------------------------------------------------------
  -- Level 3: 单姓 + 已知双字名 动态组合 (6码 = 2码姓 + 4码名)
  ------------------------------------------------------------------------------
  if #base_code == 6 then
    local s_code = base_code:sub(1, 2)
    local g_code = base_code:sub(3, 6)
    local s_trans = env.name_tr:query(s_code, make_seg(seg.start, seg.start + 2))
    local g_trans = env.name_tr:query(g_code, make_seg(seg.start + 2, seg._end))

    local s_list = {}
    if s_trans then
      for cand in s_trans:iter() do
        if count_chars(cand.text) == 1 and name_utils.is_surname(cand.text) then
          table.insert(s_list, { text = cand.text, quality = cand.quality or 0 })
        end
      end
    end

    local g_list = {}
    if g_trans then
      for cand in g_trans:iter() do
        if count_chars(cand.text) == 2 and name_utils.is_given_name_2(cand.text) then
          table.insert(g_list, { text = cand.text, quality = cand.quality or 0 })
        end
      end
    end

    for _, s in ipairs(s_list) do
      for _, g in ipairs(g_list) do
        local full = s.text .. g.text
        if not yielded[full] and (not aux_code or name_utils.match_aux(full, aux_code)) then
          local c = Candidate("name", seg.start, seg._end, full, "〔人名〕")
          c.quality = 300 + s.quality * 0.05 + g.quality * 0.05
          yield(c)
          yielded[full] = true
        end
      end
    end

    -- 复姓 4码 + 单字名 2码 (如 欧阳修)
    local cs_code = base_code:sub(1, 4)
    local sg_code = base_code:sub(5, 6)
    local cs_trans = env.name_tr:query(cs_code, make_seg(seg.start, seg.start + 4))
    local sg_trans = env.name_tr:query(sg_code, make_seg(seg.start + 4, seg._end))

    local cs_list = {}
    if cs_trans then
      for cand in cs_trans:iter() do
        if count_chars(cand.text) == 2 and name_utils.is_compound_surname(cand.text) then
          table.insert(cs_list, { text = cand.text, quality = cand.quality or 0 })
        end
      end
    end

    local sg_list = {}
    if sg_trans then
      for cand in sg_trans:iter() do
        if count_chars(cand.text) == 1 then
          table.insert(sg_list, { text = cand.text, quality = cand.quality or 0 })
        end
      end
    end

    for _, cs in ipairs(cs_list) do
      for _, sg in ipairs(sg_list) do
        local full = cs.text .. sg.text
        if not yielded[full] and (not aux_code or name_utils.match_aux(full, aux_code)) then
          local c = Candidate("name", seg.start, seg._end, full, "〔人名〕")
          c.quality = 350 + cs.quality * 0.05 + sg.quality * 0.05
          yield(c)
          yielded[full] = true
        end
      end
    end
  end

  ------------------------------------------------------------------------------
  -- Level 4: 单姓 + 已知单字名 动态组合 (4码 = 2码姓 + 2码名)
  ------------------------------------------------------------------------------
  if #base_code == 4 then
    local s_code = base_code:sub(1, 2)
    local g_code = base_code:sub(3, 4)
    local s_trans = env.name_tr:query(s_code, make_seg(seg.start, seg.start + 2))
    local g_trans = env.name_tr:query(g_code, make_seg(seg.start + 2, seg._end))

    local s_list = {}
    if s_trans then
      for cand in s_trans:iter() do
        if count_chars(cand.text) == 1 and name_utils.is_surname(cand.text) then
          table.insert(s_list, { text = cand.text, quality = cand.quality or 0 })
        end
      end
    end

    local g_list = {}
    if g_trans then
      for cand in g_trans:iter() do
        if count_chars(cand.text) == 1 then
          table.insert(g_list, { text = cand.text, quality = cand.quality or 0 })
        end
      end
    end

    for _, s in ipairs(s_list) do
      for _, g in ipairs(g_list) do
        local full = s.text .. g.text
        if not yielded[full] and (not aux_code or name_utils.match_aux(full, aux_code)) then
          local c = Candidate("name", seg.start, seg._end, full, "〔人名〕")
          c.quality = 250 + s.quality * 0.05 + g.quality * 0.05
          yield(c)
          yielded[full] = true
        end
      end
    end
  end

  ------------------------------------------------------------------------------
  -- Level 5: 复姓 + 双字名 动态组合 (8码 = 4码复姓 + 4码双字名)
  ------------------------------------------------------------------------------
  if #base_code == 8 then
    local cs_code = base_code:sub(1, 4)
    local g2_code = base_code:sub(5, 8)
    local cs_trans = env.name_tr:query(cs_code, make_seg(seg.start, seg.start + 4))
    local g2_trans = env.name_tr:query(g2_code, make_seg(seg.start + 4, seg._end))

    local cs_list = {}
    if cs_trans then
      for cand in cs_trans:iter() do
        if count_chars(cand.text) == 2 and name_utils.is_compound_surname(cand.text) then
          table.insert(cs_list, { text = cand.text, quality = cand.quality or 0 })
        end
      end
    end

    local g2_list = {}
    if g2_trans then
      for cand in g2_trans:iter() do
        if count_chars(cand.text) == 2 and name_utils.is_given_name_2(cand.text) then
          table.insert(g2_list, { text = cand.text, quality = cand.quality or 0 })
        end
      end
    end

    for _, cs in ipairs(cs_list) do
      for _, g2 in ipairs(g2_list) do
        local full = cs.text .. g2.text
        if not yielded[full] and (not aux_code or name_utils.match_aux(full, aux_code)) then
          local c = Candidate("name", seg.start, seg._end, full, "〔人名〕")
          c.quality = 350 + cs.quality * 0.05 + g2.quality * 0.05
          yield(c)
          yielded[full] = true
        end
      end
    end
  end

  ------------------------------------------------------------------------------
  -- Level 6: 单字姓氏 (2码)
  ------------------------------------------------------------------------------
  if #base_code == 2 then
    local s_trans = env.name_tr:query(base_code, make_seg(seg.start, seg._end))
    if s_trans then
      for cand in s_trans:iter() do
        if count_chars(cand.text) == 1 and name_utils.is_surname(cand.text) and not yielded[cand.text] then
          local c = Candidate("name", seg.start, seg._end, cand.text, "〔姓氏〕")
          c.quality = 200 + (cand.quality or 0) * 0.1
          yield(c)
          yielded[cand.text] = true
        end
      end
    end
  end
end

return M
