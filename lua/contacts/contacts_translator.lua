--[[
  contacts_translator.lua
  N 通讯录模式专用 Rime 翻译器：
  - 响应 ^N.*$ 编码模式
  - 严格校验 tab_mode == "contacts"，保证与普通输入完全隔离
  - 候选词显示联系人姓名与脱敏联系方式注释
  - 支持模式提示符〔☎ 通讯录〕
  - 遇到 contacts.csv 缺失或错误时，输出安全提示候选（不污染输出）
--]]

local set_mode_prompt = require("mode_prompt")
local search = require("contacts_search")
local loader = require("contacts_loader")

local M = {}

function M.init(env)
  -- 首次初始化预检测
  loader.load_contacts(false)
end

function M.func(input, seg, env)
  local query = input:match("^N(.*)$")
  if query == nil then return end

  local context = env.engine and env.engine.context
  if not context or context:get_property("tab_mode") ~= "contacts" then
    return
  end

  set_mode_prompt(env, seg, "〔☎ 通讯录〕")

  -- 根据当前输入方案动态决定全拼/双拼检索优先级
  local schema_id = (env.engine and env.engine.schema and env.engine.schema.schema_id) or ""
  local pinyin_type = "quanpin"
  local config = env.engine and env.engine.schema and env.engine.schema.config
  local configured = config and config:get_string("contacts/pinyin_type")
  if configured == "flypy" or configured == "quanpin" then
    pinyin_type = configured
  elseif schema_id:find("flypy") or schema_id:find("double_pinyin") then
    pinyin_type = "flypy"
  end

  -- 检索联系人
  local results, err = search.search(query, 50, pinyin_type)

  if err then
    local hint = "请将 contacts.csv 放入 dicts/flypy/ 目录"
    local cand = Candidate("contacts", seg.start, seg._end, "〔" .. err .. "〕", hint)
    cand.quality = 1000000
    yield(cand)
    return
  end

  if #results == 0 then
    local cand = Candidate("contacts", seg.start, seg._end, "〔未找到匹配联系人〕", "按 Esc 退出")
    cand.quality = 1000000
    yield(cand)
    return
  end

  for _, item in ipairs(results) do
    local cand = Candidate("contacts", seg.start, seg._end, item.text, item.comment)
    cand.quality = 1000000 - item.index
    yield(cand)
  end
end

return M
