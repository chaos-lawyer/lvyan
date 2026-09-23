-- 翻译器收到的 seg 是只读 Segment；提示必须写入 composition 中的可写分段。
return function(env, seg, text)
  local context = env.engine.context
  local composition = context.composition
  if composition:empty() then return end
  local current = composition:back()
  if current and current.start == seg.start and current._end == seg._end then
    current.prompt = text
  end
end
