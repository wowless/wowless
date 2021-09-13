local fns = {}
for f in require('lfs').dir('wowapi') do
  if f:sub(-4) == '.lua' then
    local fn = f:sub(1, -5)
    local t = dofile('wowapi/' .. f)
    assert(fn == t.name, ('invalid name %q in %q'):format(t.name, f))
    fns[fn] = t.status == 'unimplemented' and function() end or t.impl
  end
end
return fns
