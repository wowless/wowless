local tablex = require('pl.tablex')
local deepeq = tablex.deepcompare
local deepcopy = tablex.deepcopy

local function applyat(t, k, e)
  local tt = t[k]
  if tt == nil then
    error(('missing key %q'):format(k))
  end
  if e._add then
    assert(next(e) == '_add')
    assert(next(e, '_add') == nil)
    assert(type(tt) == 'table')
    for ek, ev in pairs(e._add) do
      if tt[ek] ~= nil then
        error(('already set key %q'):format(ek))
      end
      tt[ek] = ev
    end
  elseif e._change then
    assert(next(e) == '_change')
    assert(next(e, '_change') == nil)
    assert(deepeq(tt, e._change.from))
    t[k] = e._change.to
  else
    for ek, ev in pairs(e) do
      applyat(tt, ek, ev)
    end
  end
end

return function(v, e)
  local t = { deepcopy(v) }
  applyat(t, 1, deepcopy(e))
  return t[1]
end
