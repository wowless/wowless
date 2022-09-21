local env, id = ...
if id == 1 then
  local t = {}
  for k in pairs(env.get('ChatTypeGroup')) do
    table.insert(t, k)
  end
  table.sort(t)
  return unpack(t)
end
