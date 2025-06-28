local tablex = require('pl.tablex')
local deepeq = tablex.deepcompare
local deepcopy = tablex.deepcopy

local function check(p, msg, ...)
  if not p then
    error(msg:format(...), 2)
  end
end

local commands = {
  _add = function(t, k, e)
    local tt = t[k]
    check(type(tt) == 'table', '%q is not a table', k)
    for ek, ev in pairs(e) do
      check(tt[ek] == nil, 'already set key %q %q', k, ek)
      tt[ek] = ev
    end
  end,
  _change = function(t, k, e)
    check(deepeq(t[k], e.from), 'source match failure at %q', k)
    t[k] = e.to
  end,
  _remove = function(t, k, e)
    local tt = t[k]
    check(type(tt) == 'table', '%q is not a table', k)
    for ek, ev in pairs(e) do
      check(deepeq(tt[ek], ev), 'source match failure at %q %q', k, ek)
      tt[ek] = nil
    end
  end,
}

local function applyat(t, k, e)
  local tt = t[k]
  check(tt ~= nil, 'missing key %q', k)
  local ks = {}
  for ek, ev in pairs(e) do
    if commands[ek] then
      for evk in pairs(ev) do
        ks[evk] = (ks[evk] or 0) + 1
      end
    else
      ks[ek] = (ks[ek] or 0) + 1
    end
  end
  for kk, kv in pairs(ks) do
    check(kv == 1, 'duplicate key %q', kk)
  end
  for ek, ev in pairs(e) do
    local cmd = commands[ek]
    if cmd then
      cmd(t, k, ev)
    else
      applyat(tt, ek, ev)
    end
  end
end

return function(v, e)
  local t = { deepcopy(v) }
  applyat(t, 1, deepcopy(e))
  return t[1]
end
