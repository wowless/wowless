local UNIMPLEMENTED = function() end
local STUB_NUMBER = function() return 1 end
local STUB_TABLE = function() return {} end
local function getFn(t)
  if t.status == 'unimplemented' then
    assert(t.impl == nil)
    return UNIMPLEMENTED
  elseif t.status == 'stubnumber' then
    assert(t.impl == nil)
    return STUB_NUMBER
  elseif t.status == 'stubtable' then
    assert(t.impl == nil)
    return STUB_TABLE
  elseif t.status == 'stub' then
    return assert(t.impl)
  else
    error(('invalid status %q on %q'):format(t.status, t.name))
  end
end
local fns = {}
for f in require('lfs').dir('wowapi/api') do
  if f:sub(-4) == '.lua' then
    local fn = f:sub(1, -5)
    local t = dofile('wowapi/api/' .. f)
    assert(fn == t.name, ('invalid name %q in %q'):format(t.name, f))
    local bfn = getFn(t)
    local impl = not t.inputs and bfn or function(...)
      local sig = ''
      for i = 1, select('#', ...) do
        local ty = type((select(i, ...)))
        if ty == 'string' then
          sig = sig .. 's'
        elseif ty == 'number' then
          sig = sig .. 'n'
        else
          error(('invalid argument %d of type %q to %q'):format(i, ty, fn))
        end
      end
      assert(sig == t.inputs, ('invalid arguments to %q, expected %q, got %q'):format(fn, t.inputs, sig))
      bfn(...)
    end
    local dot = fn:find('%.')
    if dot then
      local p = fn:sub(1, dot-1)
      fns[p] = fns[p] or {}
      fns[p][fn:sub(dot+1)] = impl
    else
      fns[fn] = impl
    end
  end
end
return fns
