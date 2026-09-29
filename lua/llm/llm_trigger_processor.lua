-- Backslash starts the AI prediction request for an eligible alphabetic composition.
local M = {}
local kAccepted, kNoop = 1, 2

local function get_config_path(env)
  local schema_config = env and env.engine and env.engine.schema and env.engine.schema.config
  local custom_path = nil
  if schema_config then
    custom_path = schema_config:get_string("llm/config_path") or
                  schema_config:get_string("llm_config_path")
  end
  if custom_path and custom_path ~= "" then
    return custom_path
  end
  return "dicts/llm_config.txt"
end

local function resolve_file_path(path)
  if not path or path == "" then
    path = "dicts/llm_config.txt"
  end
  if path:match("^%a:[/\\]") or path:match("^[/\\]") then
    return path
  end
  local api = _G.rime_api
  if not api or not api.get_user_data_dir then return path end
  local user_dir = api.get_user_data_dir()
  if not user_dir or user_dir == "" then return path end
  local sep = (package.config and package.config:sub(1, 1)) or "/"
  local rel = path:gsub("[/\\]", sep)
  return user_dir .. sep .. rel
end

local function read_user_config(config_path)
  local full_path = resolve_file_path(config_path)
  local file = io.open(full_path, "rb")
  if not file then return {} end
  local values = {}
  for raw_line in file:lines() do
    local line = raw_line:gsub("^\239\187\191", "")
    line = line:match("^%s*(.-)%s*$")
    if line ~= "" and not line:match("^[#;]") then
      local key, value = line:match("^([^=]+)=(.*)$")
      if key then
        key = key:match("^%s*(.-)%s*$")
        value = value:match("^%s*(.-)%s*$")
        values[key] = value
      end
    end
  end
  file:close()
  return values
end

local function config_bool(values, key, default_val)
  local value = values[key] and values[key]:lower()
  if value == "true" or value == "1" or value == "yes" or value == "on" then
    return true
  end
  if value == "false" or value == "0" or value == "no" or value == "off" then
    return false
  end
  return default_val
end

local function valid_user_config(values)
  if not values then return false end
  if config_bool(values, "enabled", true) == false then
    return false
  end
  local trigger_key = values.trigger_key or "backslash"
  if trigger_key ~= "backslash" and trigger_key ~= "\\" then
    return false
  end
  if not values.base_url or values.base_url == "" or
     not values.api_key or values.api_key == "" or
     not values.model or values.model == "" then
    return false
  end
  return true
end

local layout_manager = require("layout_manager")

local function reset_llm_mode(context)
  if not context then return end
  if context:get_property("llm_active") == "1" then
    context:set_property("llm_active", "")
    layout_manager.sync(context)
  end
end

function M.init(env)
  local context = env.engine.context
  context:set_property("llm_trigger", "")
  context:set_property("llm_raw_input", "")
  context:set_property("llm_config_path", "")
  context:set_property("llm_active", "")

  if context.update_notifier then
    env.llm_update_conn = context.update_notifier:connect(function(ctx)
      if not ctx:is_composing() then
        reset_llm_mode(ctx)
      end
    end)
  end

  if context.commit_notifier then
    env.llm_commit_conn = context.commit_notifier:connect(function(ctx)
      reset_llm_mode(ctx)
    end)
  end
end

function M.fini(env)
  if env.llm_update_conn then
    env.llm_update_conn:disconnect()
    env.llm_update_conn = nil
  end
  if env.llm_commit_conn then
    env.llm_commit_conn:disconnect()
    env.llm_commit_conn = nil
  end
  local context = env.engine and env.engine.context
  if context then
    reset_llm_mode(context)
  end
end

function M.func(key, env)
  if key:release() then return kNoop end
  local context = env.engine.context

  local repr = key:repr()
  local is_backslash = (key.keycode == 92 or repr == "backslash" or repr == "\\") and
                       not key:ctrl() and not key:alt() and not key:super() and not key:shift()

  -- 若当前处于 LLM 激活状态：
  if context:get_property("llm_active") == "1" then
    if not is_backslash and repr ~= "Tab" and key.keycode ~= 0xff09 and key.keycode ~= 9 then
      local is_num = (repr:match("^[1-9]$") ~= nil)
      local is_space = (repr == "space" or key.keycode == 32)
      if not is_num and not is_space then
        reset_llm_mode(context)
      end
    end
  end

  if not is_backslash then
    return kNoop
  end

  local config_path = get_config_path(env)
  local user_config = read_user_config(config_path)
  if user_config.config_path and user_config.config_path ~= "" and
     user_config.config_path ~= config_path then
    config_path = user_config.config_path
    user_config = read_user_config(config_path)
  end
  if context:get_option("ascii_mode")
      or context:get_option("name_mode")
      or not context:is_composing()
      or (context:get_property("tab_mode") or "") ~= "" then
    return kNoop
  end

  local raw_input = context.input or ""
  local clean_input = raw_input:gsub("['%s]", "")
  if #clean_input < 2 or not clean_input:match("^[A-Za-z]+$") then
    return kNoop
  end

  context:set_property("llm_raw_input", raw_input)
  context:set_property("llm_config_path", config_path)
  context:set_property("llm_trigger", "1")
  context:set_property("llm_active", "1")
  if context.set_option then
    context:set_option(layout_option, true)
  end
  return kAccepted
end

return M
