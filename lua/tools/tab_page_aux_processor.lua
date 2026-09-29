--[[
  tab_page_aux_processor.lua
  Tab 下一页、Shift+Tab 上一页，并在翻页的同时进入辅助码模式。

  功能逻辑：
  1. 字母+Tab 优先：
     本处理器置于 repeat_history_processor (h+Tab/i+Tab) 和
     tab_prefix_processor (u/e/b/r/v/a/z/y/f/l+Tab 等) 之后。
     当输入命中上述功能前缀时，前面的处理器会先行消费 Tab；
  2. 普通组词翻页：
     在普通输入有候选窗（context:has_menu() 或 is_composing()）时：
     - Tab: 触发下翻页（Page_Down），并设置 tab_aux_mode = "1"
     - Shift+Tab: 触发上翻页（Page_Up），并设置 tab_aux_mode = "1"
  3. 辅助码模式联动：
     翻页激活 tab_aux_mode 后，aux_code_filter 与 direct_aux 会显示
     候选词形码提示；在组词清空、提交或取消时自动重置。
--]]

local kAccepted = 1
local kNoop = 2

local processor = {}

local function reset_aux_mode(context)
  if context and context:get_property("tab_aux_mode") == "1" then
    context:set_property("tab_aux_mode", "")
  end
end

function processor.init(env)
  local context = env.engine.context
  reset_aux_mode(context)

  env.update_conn = context.update_notifier:connect(function(ctx)
    if not ctx:is_composing() then
      reset_aux_mode(ctx)
    end
  end)

  env.commit_conn = context.commit_notifier:connect(function(ctx)
    reset_aux_mode(ctx)
  end)
end

function processor.fini(env)
  if env.update_conn then
    env.update_conn:disconnect()
    env.update_conn = nil
  end
  if env.commit_conn then
    env.commit_conn:disconnect()
    env.commit_conn = nil
  end
  local context = env.engine and env.engine.context
  if context then
    reset_aux_mode(context)
  end
end

function processor.func(key, env)
  if key:release() then return kNoop end
  if key:ctrl() or key:alt() or key:super() then return kNoop end

  local context = env.engine.context
  if not context:is_composing() then return kNoop end

  -- 若处于特殊模式（如 v 计算器、r 日期等），不干涉
  local tab_mode = context:get_property("tab_mode") or ""
  if tab_mode ~= "" then return kNoop end

  local repr = key:repr()
  local is_tab = (repr == "Tab" or key.keycode == 0xff09 or key.keycode == 9)
  local is_shift_tab = (repr == "Shift+Tab" or (is_tab and key:shift()))

  if not is_tab and not is_shift_tab then
    return kNoop
  end

  -- 确认当前有候选菜单可供翻页
  if not context:has_menu() then
    return kNoop
  end

  -- 标记进入辅助码模式
  context:set_property("tab_aux_mode", "1")

  if is_shift_tab then
    env.engine:process_key(KeyEvent("Page_Up"))
    return kAccepted
  else
    env.engine:process_key(KeyEvent("Page_Down"))
    return kAccepted
  end
end

return processor
