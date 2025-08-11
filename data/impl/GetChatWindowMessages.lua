local env = ...
return function(id)
  if id == 1 then
    local t = {}
    for k in pairs(env.env.ChatTypeGroup) do
      table.insert(t, k)
    end
    table.sort(t)
    return unpack(t)
  end
end
