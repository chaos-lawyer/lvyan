local set_mode_prompt = require("mode_prompt")

local anyou_data = require("anyou_data")
local fayuan_data = require("fayuan_data")
local zuiming_data = require("zuiming_data")
local falv_data = require("falv_data")

local M = {}

local function is_flypy_scheme(env)
  local config = env.engine and env.engine.schema and env.engine.schema.config
  if config then
    local configured = config:get_string("legal_search/pinyin_type")
    if configured == "flypy" then return true end
    if configured == "quanpin" then return false end
  end
  local schema_id = (env.engine and env.engine.schema and env.engine.schema.schema_id) or ""
  return schema_id:find("flypy") ~= nil or schema_id:find("double_pinyin") ~= nil
end

local function make_result(kind, item)
  if kind == "court" then
    return {
      kind = kind, text = item.text,
      comment = "〔法院〕〔" .. (item.comment or "") .. "·" .. (item.level or "") .. "〕",
      detail = "**人民法院**\n地区：" .. (item.comment or "未标注") .. "\n审级：" .. (item.level or "未标注"),
    }
  elseif kind == "cause" then
    return {
      kind = kind, text = item.text,
      comment = "〔案由〕〔" .. (item.tag or "民事案由") .. "〕",
      detail = "**民事案由**\n" .. (item.tag or "未标注案由级别"),
    }
  elseif kind == "crime" then
    return {
      kind = kind, text = item.text,
      comment = "〔罪名〕" .. (item.comment or ""),
      detail = "",
    }
  end
  return {
    kind = "law", text = item.text,
    comment = "〔法律〕" .. (item.comment or ""),
    detail = "",
  }
end

local function search_all(query, is_flypy)
  local sources = {
    { kind = "court", items = fayuan_data.search(query, is_flypy) },
    { kind = "cause", items = anyou_data.search(query, is_flypy) },
    { kind = "crime", items = zuiming_data.search(query, is_flypy) },
    { kind = "law", items = falv_data.search(query, is_flypy) },
  }
  local results, seen = {}, {}
  local limit = query == "" and 5 or 8
  for rank = 1, limit do
    for _, source in ipairs(sources) do
      local item = source.items[rank]
      if item then
        local key = source.kind .. "\0" .. item.text
        if not seen[key] then
          seen[key] = true
          results[#results + 1] = make_result(source.kind, item)
        end
      end
    end
  end
  return results
end

function M.translator(input, seg, env)
  local query = input:match("^F(.*)$")
  if query == nil then return end
  local context = env.engine and env.engine.context
  if not context or context:get_property("tab_mode") ~= "legal_search" then return end
  if not query:match("^[a-z]*$") then return end

  set_mode_prompt(env, seg, "〔法院·案由·罪名·法律综合检索〕")
  local results = search_all(query, is_flypy_scheme(env))
  if #results == 0 then
    local cand = Candidate("legal_search", seg.start, seg._end, "〔无匹配结果〕", "法院 / 案由 / 罪名 / 法律")
    cand.quality = 1000000
    yield(cand)
    return
  end

  for index, item in ipairs(results) do
    local cand = Candidate("legal_search", seg.start, seg._end, item.text, item.comment)
    cand.quality = 1000000 - index
    yield(cand)
  end
end

M.search_all = search_all
M.make_result = make_result
return M
