-- Ctrl+Shift+E 英文检索模式：仅保留专属词典的英文补全候选。
local M = {}

function M.func(input, env)
  local context = env.engine.context
  local enabled = (context:get_property("tab_mode") or "") == "english"
  local segment = context.composition:back()
  local english_segment = segment and segment:has_tag("english_filter")

  for cand in input:iter() do
    if enabled or english_segment then
      -- table_translator 的候选 type 在不同 Rime 发行版中并不稳定，
      -- 因此按候选文本过滤；允许常见英文中的数字、标点与空格。
      if (cand.text or ""):match("^[A-Za-z][A-Za-z0-9%p%s]*$") then
        yield(cand)
      end
    elseif cand.type ~= "english_filter" then
      -- 英文前缀未命中时，不让专属翻译器参与普通中文输入。
      yield(cand)
    end
  end
end

return M
