local product, filename = unpack(arg)

local data
do
  local env = {}
  setfenv(loadfile(filename), env)()
  data = env.WowlessLastTestFailures
end

local yaml = require('wowapi.yaml')
local write = require('pl.file').write

local getPatternValue = (function()
  local function constant(x)
    return function()
      return x
    end
  end
  local function mustnumber(x)
    return assert(tonumber(x))
  end
  local patterns = {
    {
      pattern = ': cvar name mismatch: want ',
      value = constant(nil),
    },
    {
      pattern = ': want %-?%d+, got (-?%d+)$',
      value = mustnumber,
    },
    {
      pattern = ': want ".*", got "nil"$',
      value = constant(nil),
    },
    {
      pattern = ': want ".*", got nil$',
      value = constant(nil),
    },
    {
      pattern = ': want ".*", got "(.*)"$',
      value = tostring,
    },
    {
      pattern = ': want nil, got "(.*)"$',
      value = tostring,
    },
    {
      pattern = ': missing, has value (-?%d+)$',
      value = mustnumber,
    },
    {
      pattern = ': extra cvar "[^"]*"$',
      value = constant(nil),
    },
    {
      pattern = ': missing cvar with default "(.*)"$',
      value = tostring,
    },
    {
      pattern = ': missing key ".+" with value (-?[0-9.]+)$',
      value = mustnumber,
    },
    {
      pattern = ': missing key ".+" with value (0x0000[01248]+)$',
      value = tostring,
    },
    {
      pattern = ': missing key ".+" with value table: [0-9a-fA-Fx]+$',
      value = constant({}),
    },
  }

  local function forwardValue(a1, ...)
    assert(select('#', ...) == 0)
    return a1
  end

  local function forwardMatch(fn, a1, ...)
    if a1 then
      return true, forwardValue(fn(a1, ...))
    end
  end

  return function(v)
    for _, p in ipairs(patterns) do
      local match, value = forwardMatch(p.value, v:match(p.pattern))
      if match then
        return true, value
      end
    end
    print(('warning: no pattern matched %q'):format(v))
  end
end)()

local function applyPatterns(tx, ty)
  for k, v in pairs(ty) do
    if type(v) == 'table' then
      applyPatterns(tx[k], v)
    else
      local match, value = getPatternValue(v)
      if match then
        tx[k] = value
      end
    end
  end
end

if data.generated.cvars then
  local cvarsfile = 'data/products/' .. product .. '/cvars.yaml'
  local cvars = yaml.parseFile(cvarsfile)
  applyPatterns(cvars, data.generated.cvars)
  write(cvarsfile, yaml.pprint(cvars))
end

if data.generated.globals then
  local gf = 'data/products/' .. product .. '/globals.yaml'
  local g = yaml.parseFile(gf)
  applyPatterns(g, data.generated.globals or {})
  write(gf, yaml.pprint(g))
end

do
  local fn = 'data/products/' .. product .. '/apis.yaml'
  local apis = yaml.parseFile(fn)
  for ns, nt in pairs(data.generated.apiNamespaces or {}) do
    if type(nt) == 'string' then
      if nt:match(': want "nil", got "table"$') then
        -- This means we're missing the namespace completely, but unfortunately right now
        -- generated.lua doesn't tell us what APIs are missing, so given our current data
        -- model we can't actually remedy this yet.
        print('missing ' .. ns)
      elseif nt:match(': want "table", got "nil"$') then
        local pre = ns .. '.'
        for k in pairs(apis) do
          if k:sub(1, pre:len()) == pre then
            apis[k] = nil
          end
        end
      else
        error('unexpected string: ' .. nt)
      end
    elseif type(nt) == 'table' then
      for mn, mv in pairs(nt) do
        local funcname = ns .. '.' .. mn
        if type(mv) == 'string' then
          assert(mv:match(': want "function", got "nil"$'))
          apis[funcname] = nil
        elseif type(mv) == 'table' then
          assert(next(mv) == 'impltype')
          assert(next(mv, 'impltype') == nil)
          if mv.impltype:match(': want true, got false$') then
            apis[funcname] = {}
          elseif mv.impltype:match(': want false, got true$') then
            apis[funcname] = nil
          else
            error('unexpected error on ' .. funcname)
          end
        else
          error('unexpected type for ' .. ns .. '.' .. mn)
        end
      end
    else
      error('unexpected type for ' .. ns)
    end
  end
  write(fn, yaml.pprint(apis))
end

do
  local fn = 'data/products/' .. product .. '/events.yaml'
  local evs = yaml.parseFile(fn)
  for k, v in pairs(data.generated.events or {}) do
    if v:match(': want true, got false$') then
      evs[k] = nil
    elseif v:match(': want false, got true$') then
      evs[k] = { payload = {} }
    else
      error('unexpected pattern for ' .. k)
    end
  end
  write(fn, yaml.pprint(evs))
end

do
  local fn = 'data/products/' .. product .. '/apis.yaml'
  local apis = yaml.parseFile(fn)
  for k, v in pairs(data.generated.globalApis or {}) do
    if type(v) == 'string' then
      assert(v:match(': want "function", got "nil"$'))
      apis[k] = nil
    elseif type(v) == 'table' then
      assert(next(v) == 'impltype', ('%q: expected impltype, got %q'):format(k, next(v)))
      assert(next(v, 'impltype') == nil)
      if v.impltype:match(': want true, got false$') then
        apis[k] = {}
      elseif v.impltype:match(': want false, got true$') then
        apis[k] = nil
      else
        error(k)
      end
    else
      error('invalid type at globalApi ' .. k)
    end
  end
  write(fn, yaml.pprint(apis))
end

for k, v in pairs(data.generated.uiobjects or {}) do
  if v.methods then
    for mk, mv in pairs(v.methods) do
      if mv:match(': missing$') or mv:match(': product disabled: want "nil", got "function"') then
        print('add ' .. k .. '.' .. mk)
      elseif mv:match(': want "function", got "nil"$') then
        print('delete ' .. k .. '.' .. mk)
      else
        error('weird error for ' .. k .. '.' .. mk)
      end
    end
  end
end
