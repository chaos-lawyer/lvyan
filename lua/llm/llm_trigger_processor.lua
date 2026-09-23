-- LLM is a Tab-only fallback. Earlier processors own special Tab modes;
-- this processor records an eligible ordinary alphabetic composition for
-- the Weasel-side asynchronous request handler.
local M = {}
local kAccepted, kNoop = 1, 2

local function config_bool(config, path, fallback)
  local value = config:get_bool(path)
  if value == nil then return fallback end
  return value
end

function M.init(env)
  env.engine.context:set_property("llm_trigger", "")
  env.engine.context:set_property("llm_raw_input", "")
end

function M.func(key, env)
  if key:release() then return kNoop end
  local context = env.engine.context
  local config = env.engine.schema.config

  if key:repr() ~= "Tab" or key:ctrl() or key:alt() or key:super() then
    return kNoop
  end
  if not config_bool(config, "llm/enabled", false)
      or not config:get_string("llm/base_url")
      or config:get_string("llm/base_url") == ""
      or not config:get_string("llm/model")
      or config:get_string("llm/model") == ""
      or context:get_option("ascii_mode")
      or context:get_option("name_mode")
      or not context:is_composing()
      or (context:get_property("tab_mode") or "") ~= "" then
    return kNoop
  end

  local raw_input = context.input or ""
  if #raw_input < 2 or not raw_input:match("^[A-Za-z]+$") then
    return kNoop
  end

  context:set_property("llm_raw_input", raw_input)
  context:set_property("llm_trigger", "1")
  return kAccepted
end

return M
