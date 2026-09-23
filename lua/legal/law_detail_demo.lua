--[[
  law_detail_demo.lua
  候选详情面板通用能力示例插件 (Candidate Detail Panel Demo)
  
  原理：
  监听 Rime Context 的候选选择与高亮变更事件，当当前高亮候选匹配到详情数据库中的内容时，
  通过 context:set_property("candidate_detail", detail_text) 将详情文本注入 Context Property。
  Weasel 主程序在检测到 candidate_detail_panel.enabled: true 且当前候选存在详情时，
  会在候选窗口旁弹出自适应的独立详情面板进行展示。
--]]

local M = {}

-- 通用候选详情数据库（可由外部 Lua 模块、JSON 或 SQLite 动态提供）
local candidate_details_db = {
  ["中华人民共和国公司法"] = table.concat({
    "发布机关：全国人大常委会",
    "文号：主席令第15号",
    "公布日期：2023-12-29",
    "施行日期：2024-07-01",
    "效力级别：法律",
    "时效性：现行有效"
  }, "\n"),
  ["公司法"] = table.concat({
    "发布机关：全国人大常委会",
    "文号：主席令第15号",
    "公布日期：2023-12-29",
    "施行日期：2024-07-01",
    "效力级别：法律",
    "时效性：现行有效"
  }, "\n"),
  ["中华人民共和国民法典"] = table.concat({
    "发布机关：全国人民代表大会",
    "文号：主席令第45号",
    "公布日期：2020-05-28",
    "施行日期：2021-01-01",
    "效力级别：法律",
    "时效性：现行有效"
  }, "\n"),
  ["民法典"] = table.concat({
    "发布机关：全国人民代表大会",
    "文号：主席令第45号",
    "公布日期：2020-05-28",
    "施行日期：2021-01-01",
    "效力级别：法律",
    "时效性：现行有效"
  }, "\n"),
  ["中华人民共和国刑法"] = table.concat({
    "发布机关：全国人民代表大会",
    "文号：主席令第83号",
    "公布日期：1997-03-14",
    "施行日期：1997-10-01",
    "效力级别：法律",
    "时效性：现行有效"
  }, "\n"),
  ["刑法"] = table.concat({
    "发布机关：全国人民代表大会",
    "文号：主席令第83号",
    "公布日期：1997-03-14",
    "施行日期：1997-10-01",
    "效力级别：法律",
    "时效性：现行有效"
  }, "\n"),
}

local function sync_detail(context)
  if not context:is_composing() then
    context:set_property("candidate_detail", "")
    return
  end

  local composition = context.composition
  if not composition or composition:empty() then
    context:set_property("candidate_detail", "")
    return
  end

  local seg = composition:back()
  if not seg then
    context:set_property("candidate_detail", "")
    return
  end

  local cand = seg:get_selected_candidate()
  if not cand then
    context:set_property("candidate_detail", "")
    return
  end

  local detail = candidate_details_db[cand.text]
  if detail and #detail > 0 then
    context:set_property("candidate_detail", detail)
  else
    context:set_property("candidate_detail", "")
  end
end

function M.init(env)
  local context = env.engine.context
  sync_detail(context)

  env.detail_update_connection = context.update_notifier:connect(function(ctx)
    sync_detail(ctx)
  end)

  env.detail_select_connection = context.select_notifier:connect(function(ctx)
    sync_detail(ctx)
  end)
end

function M.fini(env)
  if env.detail_update_connection then
    env.detail_update_connection:disconnect()
    env.detail_update_connection = nil
  end
  if env.detail_select_connection then
    env.detail_select_connection:disconnect()
    env.detail_select_connection = nil
  end
  local context = env.engine and env.engine.context
  if context then
    context:set_property("candidate_detail", "")
  end
end

function M.func(key, env)
  -- 纯处理器，不做按键拦截，返回 2 (kNoop) 交由上游正常处理
  return 2
end

return M
