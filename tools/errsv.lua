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
  local function boolOrString(x)
    if x == 'true' then
      return true
    elseif x == 'false' then
      return false
    else
      return x
    end
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
    {
      pattern = ': missing key ".+" with value (%a[%w_]*)$',
      value = boolOrString,
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
    error(('no pattern matched %q'):format(v), 0)
  end
end)()

local function applyPatterns(tx, ty)
  for k, v in pairs(ty) do
    if type(v) == 'table' then
      if tx[k] == nil then
        tx[k] = {}
      end
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
  local gv = data.generated.globals
  local enumkey, enumtable, enumvalue
  if type(gv) == 'string' then
    enumkey = gv:match('^enums_set_in_framexml (.+) was not set$')
    enumtable, enumvalue = gv:match('^enum_values_set_in_framexml (.+)%.(.+) was not set$')
  end
  if enumkey then
    local cf = 'data/products/' .. product .. '/config.yaml'
    local config = yaml.parseFile(cf)
    config.addon.enums_set_in_framexml[enumkey] = nil
    write(cf, yaml.pprint(config))
  elseif enumtable then
    local cf = 'data/products/' .. product .. '/config.yaml'
    local config = yaml.parseFile(cf)
    config.addon.enum_values_set_in_framexml[enumtable][enumvalue] = nil
    write(cf, yaml.pprint(config))
  else
    local gf = 'data/products/' .. product .. '/globals.yaml'
    local g = yaml.parseFile(gf)
    if gv.Enum then
      for k in pairs(gv.Enum) do
        local base = k:match('^(.+)Meta$')
        if base and ((g.Enum or {})[base] or gv.Enum[base]) then
          gv.Enum[k] = nil
        end
      end
    end
    applyPatterns(g, gv)
    if gv.Enum then
      for k in pairs(gv.Enum) do
        local ev = g.Enum[k]
        if type(ev) == 'table' and next(ev) == nil then
          ev.Placeholder = 1
        end
      end
    end
    write(gf, yaml.pprint(g))
  end
end

do
  local fn = 'data/products/' .. product .. '/apis.yaml'
  local apis = yaml.parseFile(fn)
  local cf = 'data/products/' .. product .. '/config.yaml'
  local config
  local configDirty = false
  local function overwrittenApis()
    config = config or yaml.parseFile(cf)
    configDirty = true
    return config.addon.overwritten_apis
  end
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
            overwrittenApis()[funcname] = nil
          elseif mv.impltype:match(': want false, got true$') then
            -- A Lua function here could mean a real C API shadowed by a Lua wrapper
            -- (belongs in overwritten_apis) or just a Lua-implemented stub with no C
            -- API underneath (does not). We can't tell which from here.
            print('lua function: ' .. funcname)
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
  if configDirty then
    write(cf, yaml.pprint(config))
  end
end

do
  local fn = 'data/products/' .. product .. '/apis.yaml'
  local apis = yaml.parseFile(fn)
  local cf = 'data/products/' .. product .. '/config.yaml'
  local config
  local configDirty = false
  local function overwrittenApis()
    config = config or yaml.parseFile(cf)
    configDirty = true
    return config.addon.overwritten_apis
  end
  for k, v in pairs(data.generated.globalApis or {}) do
    if type(v) == 'string' then
      assert(v:match(': want "function", got "nil"$'))
      apis[k] = nil
    elseif type(v) == 'table' then
      assert(next(v) == 'impltype', ('%q: expected impltype, got %q'):format(k, next(v)))
      assert(next(v, 'impltype') == nil)
      if v.impltype:match(': want true, got false$') then
        overwrittenApis()[k] = nil
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
  if configDirty then
    write(cf, yaml.pprint(config))
  end
end

if data.generated['~cfuncs'] then
  local fn = 'data/products/' .. product .. '/apis.yaml'
  local apis = yaml.parseFile(fn)
  for k, v in pairs(data.generated['~cfuncs']) do
    local names = {}
    for name in k:gmatch('"([^"]*)"') do
      table.insert(names, name)
    end
    if v:match(': no true name$') then
      assert(#names == 1, k)
      apis[names[1]] = {}
    elseif v:match(': multiple true names$') then
      local namespaced, aliases = {}, {}
      for _, name in ipairs(names) do
        if name:find('%.') then
          table.insert(namespaced, name)
        else
          table.insert(aliases, name)
        end
      end
      local nsapi = #namespaced == 1 and apis[namespaced[1]]
      local hasStub = false
      for _, o in ipairs(nsapi and nsapi.outputs or {}) do
        if o.stub ~= nil then
          hasStub = true
        end
      end
      if #namespaced == 1 and #aliases == #names - 1 and nsapi and not nsapi.impl and not hasStub then
        for _, name in ipairs(aliases) do
          apis[name] = nil
        end
      else
        print('multiple true names: ' .. table.concat(names, ', '))
      end
    else
      error('unexpected cfuncs error: ' .. v)
    end
  end
  write(fn, yaml.pprint(apis))
end

if data.luaobjects and data.luaobjects.types then
  local fn = 'data/products/' .. product .. '/luaobjects.yaml'
  local luaobjects = yaml.parseFile(fn)
  for k, v in pairs(data.luaobjects.types) do
    if type(v) == 'string' then
      local suffix = ': ' .. k
      assert(v:sub(-#suffix) == suffix, k)
      assert(not luaobjects[k].virtual, k)
      luaobjects[k].virtual = true
    end
  end
  write(fn, yaml.pprint(luaobjects))
end

do
  local fn = 'data/products/' .. product .. '/uiobjects.yaml'
  local uiobjects
  local dirty = false
  for k, v in pairs(data.generated.uiobjects or {}) do
    if v.methods then
      for mk, mv in pairs(v.methods) do
        if k == 'GameTooltip' and mv:match(': missing$') then
          uiobjects = uiobjects or yaml.parseFile(fn)
          assert(uiobjects[k].methods[mk] == nil, mk)
          uiobjects[k].methods[mk] = {}
          dirty = true
        elseif mv:match(': missing$') or mv:match(': product disabled: want "nil", got "function"') then
          print('add ' .. k .. '.' .. mk)
        elseif mv:match(': want "function", got "nil"$') then
          print('delete ' .. k .. '.' .. mk)
        else
          error('weird error for ' .. k .. '.' .. mk)
        end
      end
    end
  end
  if dirty then
    write(fn, yaml.pprint(uiobjects))
  end
end
