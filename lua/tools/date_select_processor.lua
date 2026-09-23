--[[
  date_select_processor.lua
  在 R 日期模式下处理候选选择：
  1. 参照 LPR 模式，使用 a/b/c/d/e（及 A/B/C/D/E）作为候选词选择键，
     对应选择当前页的第 1, 2, 3, 4, 5 个候选。
  2. 主键盘数字键 0~9 严禁作为选词键，完全作为日期与运算表达式的输入字符。
  3. 支持 Tab / Down 移动光标选择候选，空格直接上屏第一候选。
--]]

local kAccepted = 1
local kNoop = 2

local key_map = {
  a = 1, b = 2, c = 3, d = 4, e = 5,
  A = 1, B = 2, C = 3, D = 4, E = 5,
}

local function is_complete_date_expression(input)
    if not input or not input:match("^R") then
        return false
    end
    -- 缩写指令：Rrq, Rsj, Rdt, Rxq, Rnl 等
    if input:match("^R[Ff]?rq$") or input == "Rsj" or input == "Rdt" or input == "Rxq" or input == "Rnl" then
        return true
    end
    -- 恰好 8 位指定日期（如 R20260918, Rf20260918）
    if input:match("^R[Ff]?%d%d%d%d%d%d%d%d$") then
        return true
    end
    -- 带单位或顺延标识的运算结尾：+1y, -1n, +5g, +15f, +f, -f, Rf, R20260918f 等
    if input:match("[%+%-]%d*[nygfsm]$") or input:match("^R[Ff]?f$") or input:match("^R[Ff]?%d%d%d%d%d%d%d%df$") then
        return true
    end
    -- 纯数字运算结尾（如 R+30, R-5, R20260918+30-5, R+10-8 等）
    if input:match("[%+%-]%d+$") then
        return true
    end
    -- 两个日期的间隔（如 R20260901-20260918 或 R-20260918，带或不带 g）
    if input:match("^R[Ff]?%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d%d%d[g]?$") or input:match("^R[Ff]?%-%d%d%d%d%d%d%d%d[g]?$") then
        return true
    end
    return false
end

local layout_option = "vertical_layout"

local function is_vertical_mode_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  return (tab_mode == "r" or tab_mode == "rf" or tab_mode == "lpr" or tab_mode == "v"
    or tab_mode == "anyou" or tab_mode == "zuiming" or tab_mode == "fayuan" or tab_mode == "falv" or tab_mode == "fenshu")
end

local function is_letter_select_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  return (tab_mode == "r" or tab_mode == "rf" or tab_mode == "lpr" or tab_mode == "v" or tab_mode == "fenshu")
end

local select_keys_property = "candidate_select_keys"

local function is_law_number_context(context)
  return context:is_composing() and (context.input or ""):match("^[Dd]%d+$") ~= nil
end

local function is_date_context(context)
  if not context:is_composing() then
    return false
  end
  local tab_mode = context:get_property("tab_mode") or ""
  return (tab_mode == "r" or tab_mode == "rf")
end

local is_syncing = false

local function sync_mode(context)
  if is_syncing then return end
  is_syncing = true

  local should_be_vertical = is_vertical_mode_context(context)
  if context:get_option(layout_option) ~= should_be_vertical then
    context:set_option(layout_option, should_be_vertical)
  end

  local in_date = is_date_context(context)
  local cur_keys = context:get_property(select_keys_property) or ""
  if in_date then
    if cur_keys ~= "abcde" then
      context:set_property(select_keys_property, "abcde")
    end
  else
    if cur_keys == "abcde" and not is_letter_select_context(context) and not is_law_number_context(context) then
      context:set_property(select_keys_property, "")
    end
  end

  is_syncing = false
end

local processor = {}

function processor.init(env)
    local context = env.engine.context
    env.page_size = 5
    if env.engine.schema and env.engine.schema.config then
        env.page_size = env.engine.schema.config:get_int("menu/page_size") or 5
    end
    sync_mode(context)
    env.date_layout_connection = context.update_notifier:connect(function(ctx)
        sync_mode(ctx)
    end)
end

function processor.fini(env)
    if env.date_layout_connection then
        env.date_layout_connection:disconnect()
        env.date_layout_connection = nil
    end

    local context = env.engine and env.engine.context
    if context then
        if context:get_option(layout_option) then
            context:set_option(layout_option, false)
        end
        if context:get_property(select_keys_property) == "abcde" then
            context:set_property(select_keys_property, "")
        end
    end
end

function processor.func(key, env)
    if key:release() then return kNoop end
    if key:ctrl() or key:alt() or key:super() then return kNoop end

    local context = env.engine.context
    if not context:is_composing() or not context:has_menu() then
        return kNoop
    end

    local input = context.input or ""
    if not input:match("^R") then
        return kNoop
    end

    local key_repr = key:repr()
    local sel_num = key_map[key_repr]

    -- 参照 LPR 模式，使用 a/b/c/d/e 选词
    if sel_num then
        local should_select = false
        if is_complete_date_expression(input) then
            should_select = true
        elseif input == "R" or input == "Rf" then
            -- 在初始单个 R 模式下，a, b, c, e 可选词；d 保留给输入 Rdt 指令
            if key_repr ~= "d" and key_repr ~= "D" then
                should_select = true
            end
        end

        if should_select then
            local composition = context.composition
            if composition and not composition:empty() then
                local seg = composition:back()
                local menu = seg and seg.menu
                if menu and not menu:empty() and menu:candidate_count() > 0 then
                    local page_sz = env.page_size or 5
                    local sel_index = seg.selected_index or 0
                    local page_start = math.floor(sel_index / page_sz) * page_sz
                    local index = page_start + (sel_num - 1)
                    if index < menu:candidate_count() then
                        if context:select(index) then
                            return kAccepted
                        end
                        local cand = menu:get_candidate_at(index)
                        if cand then
                            env.engine:commit_text(cand.text)
                            context:clear()
                            return kAccepted
                        end
                    end
                end
            end
        end
    end

    return kNoop
end

return processor
