--[[
  initials_mode_processor.lua
  首拼模式处理器（仅后置触发）：
  1. 仅支持「先输入编码，再按 \」切换为纯首拼模式（如 bj\、kfd\、cght\）；
  2. 不支持前置 \ 启动首拼模式：在空输入时按 \，直接输出顿号「、」；
  3. 若在首拼模式下再次按 \，可反向切换回常规双拼；
  4. 按 Esc 彻底清空并退出，绝不残留首拼模式提示；
  5. 退格至首拼模式末位字符时，直接彻底退出，避免残留 naked 前缀。
--]]

local kAccepted = 1
local kNoop = 2

local processor = {}

function processor.init(env)
end

function processor.fini(env)
end

function processor.func(key, env)
  if key:release() then return kNoop end
  if key:ctrl() or key:alt() or key:super() then
    return kNoop
  end

  local context = env.engine.context
  if context:get_option("ascii_mode") then
    return kNoop
  end

  local repr = key:repr()
  local is_backslash = (key.keycode == 92 or repr == "backslash" or repr == "\\") and not key:shift()
  local is_escape = (repr == "Escape" or key.keycode == 0xff1b or key.keycode == 27)
  local is_backspace = (repr == "BackSpace" or repr == "Backspace" or key.keycode == 0xff08 or key.keycode == 8)

  local inp = context.input or ""

  -- 按 Escape：在首拼模式下直接彻底清空并退出，消除首拼模式提示
  if is_escape and inp:sub(1, 1) == "\\" then
    context:clear()
    return kAccepted
  end

  -- 按 Backspace：若首拼模式下仅剩 1 个字母或 naked "\"，直接彻底清空退出
  if is_backspace and inp:sub(1, 1) == "\\" and #inp <= 2 then
    context:clear()
    return kAccepted
  end

  -- 禁止前置 \ 启动首拼：如果当前输入为空，按 \ 直接上屏顿号「、」
  if is_backslash and inp == "" then
    env.engine:commit_text("、")
    return kAccepted
  end

  -- 核心场景：仅后置 \ 启动首拼。已输入编码，按 \ 在常规模式与首拼模式间即时无缝切换
  if is_backslash and inp ~= "" then
    if inp:sub(1, 1) == "\\" then
      -- 已在首拼模式（且多于单个 "\"）：再次按 \ 切回普通双拼
      local raw = inp:sub(2)
      context:clear()
      context:push_input(raw)
      return kAccepted
    else
      -- 核心场景：先输入编码（如 bj / kfd），按 \ 即刻转换为首拼模式
      context:clear()
      context:push_input("\\" .. inp)
      return kAccepted
    end
  end

  return kNoop
end

return processor
