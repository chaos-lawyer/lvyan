-- Temporary Word input diagnostic. Logs event metadata only, never input or text.
local M = {}

local sequence = 0
local known_modes = {
  anyou = true, zuiming = true, fayuan = true, falv = true,
  lpr = true, r = true, rf = true, v = true, fenshu = true,
}

local function is_word(context)
  local app = context:get_property("client_app") or ""
  return app:lower() == "winword.exe"
end

local function mode_name(context)
  local mode = context:get_property("tab_mode") or ""
  if mode == "" then return "none" end
  return known_modes[mode] and mode or "other"
end

local function candidate_type(candidate)
  if not candidate then return "none" end
  local kind = candidate.type or ""
  if type(kind) ~= "string" or not kind:match("^[%a_][%w_]*$") or #kind > 32 then
    return "other"
  end
  return kind
end

local function selected_type(context)
  if not context.get_selected_candidate then return "none" end
  local candidate = context:get_selected_candidate()
  if not candidate then return "none" end
  if candidate.get_genuine then
    local ok, genuine = pcall(function() return candidate:get_genuine() end)
    if ok and genuine then candidate = genuine end
  end
  return candidate_type(candidate)
end

local function state(context)
  return string.format("composing=%d menu=%d mode=%s vertical=%d",
    context:is_composing() and 1 or 0,
    context:has_menu() and 1 or 0,
    mode_name(context),
    context:get_option("vertical_layout") and 1 or 0)
end

local function record(event, details, context)
  if not is_word(context) or not _G.log or not _G.log.info then return end
  sequence = sequence + 1
  _G.log.info(string.format("[word_commit_probe] seq=%d event=%s %s %s",
    sequence, event, details or "", state(context)))
end

function M.init(env)
  local config = env.engine.schema.config
  if config:get_bool("word_commit_probe/enabled") ~= true then return end

  local context = env.engine.context
  env.word_probe_select = context.select_notifier:connect(function(ctx)
    record("select", "type=" .. selected_type(ctx), ctx)
  end)
  env.word_probe_commit = context.commit_notifier:connect(function(ctx)
    local value = ctx.get_commit_text and ctx:get_commit_text() or ""
    record("commit", "bytes=" .. tostring(#value), ctx)
  end)
  env.word_probe_update = context.update_notifier:connect(function(ctx)
    if not is_word(ctx) then return end
    local current = state(ctx)
    if current ~= env.word_probe_last_state then
      env.word_probe_last_state = current
      record("state", "", ctx)
    end
  end)
end

function M.func()
  return 2 -- kNoop: observe without handling the key.
end

function M.fini(env)
  for _, key in ipairs({"word_probe_select", "word_probe_commit", "word_probe_update"}) do
    local connection = env[key]
    if connection then connection:disconnect() end
    env[key] = nil
  end
end

return M
