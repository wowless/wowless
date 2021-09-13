local UNIMPLEMENTED = function() end
local STUB_NUMBER = function() return 1 end
local function getFn(t)
  if t.status == 'unimplemented' then
    return UNIMPLEMENTED
  elseif t.status == 'stubnumber' then
    return STUB_NUMBER
  else
    return assert(t.impl)
  end
end
local fns = {}
for f in require('lfs').dir('wowapi') do
  if f:sub(-4) == '.lua' then
    local fn = f:sub(1, -5)
    local t = dofile('wowapi/' .. f)
    assert(fn == t.name, ('invalid name %q in %q'):format(t.name, f))
    fns[fn] = getFn(t)
  end
end
return fns
