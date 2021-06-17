local function mixin(t, ...)
  for _, kv in ipairs({...}) do
    for k, v in pairs(kv) do
      t[k] = v
    end
  end
  return t
end

local function tappend(t, t2)
  for _, v in ipairs(t2) do
    table.insert(t, v)
  end
  return t
end

return {
  mixin = mixin,
  tappend = tappend,
}
