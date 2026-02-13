local deps = {}

local function readfile(f)
  deps[f] = true
  return assert((require('pl.file').read(f)))
end

local function readyaml(f)
  return require('wowapi.yaml').parse(readfile(f))
end

local function perproduct(p, f)
  return readyaml(('data/products/%s/%s.yaml'):format(p, f))
end

local function tpath(t, ...)
  for i = 1, select('#', ...) do
    assert(type(t) == 'table')
    t = t[(select(i, ...))]
    if t == nil then
      return nil
    end
  end
  return t
end

local ptablemap = {
  build = function(p)
    return 'Build', perproduct(p, 'build')
  end,
  config = function(p)
    return 'Config', perproduct(p, 'config')
  end,
  cvars = function(p)
    return 'CVars', perproduct(p, 'cvars')
  end,
  events = function(p)
    local t = {}
    for k, v in pairs(perproduct(p, 'events')) do
      t[k] = {
        callback = v.callback or false,
        payload = #v.payload,
        registerable = not v.noscript,
        restricted = v.restricted,
      }
    end
    for _, product in ipairs(readyaml('data/products.yaml')) do
      for k in pairs(perproduct(product, 'events')) do
        if not t[k] then
          t[k] = {
            callback = false,
            payload = -1,
            registerable = false,
          }
        end
      end
    end
    return 'Events', t
  end,
  globalapis = function(p)
    local config = perproduct(p, 'config')
    local t = {}
    for name in pairs(perproduct(p, 'apis')) do
      if not name:find('%.') then
        local vv = {
          overwritten = tpath(config, 'addon', 'overwritten_apis', name) and true,
        }
        t[name] = next(vv) and vv or true
      end
    end
    return 'GlobalApis', t
  end,
  globals = function(p)
    return 'Globals', perproduct(p, 'globals')
  end,
  impltests = function(p)
    local test = readyaml('data/test.yaml')
    local t = {}
    for _, api in pairs(perproduct(p, 'apis')) do
      if test[api.impl] and not t[api.impl] then
        t[api.impl] = readfile('data/test/' .. api.impl .. '.lua')
      end
    end
    return 'ImplTests', t
  end,
  luaobjects = function(p)
    local raw = perproduct(p, 'luaobjects')
    -- For each luaobject type, a mapping of method name to the luaobject type it came from.
    local t = {}
    local function pop(k)
      if t[k] then
        return
      end
      local v = raw[k]
      local methods = {}
      if v.inherits then
        pop(v.inherits)
        for mk, mv in pairs(t[v.inherits]) do
          methods[mk] = mv
        end
      end
      for mk in pairs(v.methods or {}) do
        methods[mk] = k
      end
      t[k] = methods
    end
    for k in pairs(raw) do
      pop(k)
    end
    for k, v in pairs(raw) do
      if v.virtual then
        t[k] = nil
      end
    end
    -- Method partition: name from base type to list of names from all derived types.
    local mp = {}
    for k, v in pairs(t) do
      for vk, vv in pairs(v) do
        local ck = vv .. '/' .. vk
        local cv = mp[ck]
        if not cv then
          cv = {}
          mp[ck] = cv
        end
        table.insert(cv, k .. '/' .. vk)
      end
    end
    -- Compressed method partition, more easily computable addon-side.
    local cmp = {}
    for _, v in pairs(mp) do
      table.sort(v)
      local k = table.concat(v, ',')
      assert(not cmp[k])
      cmp[k] = true
    end
    -- Type to set of method names.
    local types = {}
    for k, v in pairs(t) do
      local m = {}
      for vk in pairs(v) do
        m[vk] = true
      end
      types[k] = m
    end
    return 'LuaObjects', {
      methodpartition = cmp,
      types = types,
    }
  end,
  namespaceapis = function(p)
    local platform = dofile('build/cmake/runtime/platform.lua')
    local config = perproduct(p, 'config')
    local apiNamespaces = {}
    for k, api in pairs(perproduct(p, 'apis')) do
      local dot = k:find('%.')
      if dot and (not api.platform or api.platform == platform) and not api.secureonly then
        local name = k:sub(1, dot - 1)
        apiNamespaces[name] = apiNamespaces[name] or { methods = {} }
        apiNamespaces[name].methods[k:sub(dot + 1)] = api
      end
    end
    local t = {}
    for k, v in pairs(apiNamespaces) do
      local mt = {}
      for mk in pairs(v.methods) do
        local tt = {
          overwritten = tpath(config, 'addon', 'overwritten_apis', k .. '.' .. mk) and true,
        }
        mt[mk] = next(tt) and tt or true
      end
      t[k] = mt
    end
    return 'NamespaceApis', t
  end,
  uiobjectapis = function(p)
    local uiobjects = perproduct(p, 'uiobjects')
    local allscripts = readyaml('data/scripttypes.yaml')
    for _, cfg in pairs(uiobjects) do
      cfg.fieldinitoverrides = cfg.fieldinitoverrides or {}
    end
    for k, cfg in pairs(uiobjects) do
      cfg.isa = {}
      for k2, cfg2 in pairs(uiobjects) do
        cfg.isa[k2] = false
        if cfg2.objectType then
          cfg.isa[cfg2.objectType] = false
        end
      end
      if not cfg.virtual or cfg.objectType then
        cfg.isa[cfg.objectType or k] = true
      end
    end
    local function fixup(cfg)
      for inhname in pairs(cfg.inherits) do
        local inh = uiobjects[inhname]
        fixup(inh)
        for n, f in pairs(inh.fieldinitoverrides) do
          cfg.fieldinitoverrides[n] = f
        end
        for n, f in pairs(inh.fields) do
          cfg.fields[n] = f
        end
        for n, m in pairs(inh.methods) do
          cfg.methods[n] = cfg.methods[n] or m -- overrides
        end
        if inh.scripts then
          cfg.scripts = cfg.scripts or {}
          for n in pairs(inh.scripts) do
            cfg.scripts[n] = {}
          end
        end
        for ik, iv in pairs(inh.isa) do
          if iv then
            cfg.isa[ik] = true
          end
        end
      end
    end
    for _, cfg in pairs(uiobjects) do
      fixup(cfg)
    end
    local t = {}
    for k, v in pairs(uiobjects) do
      local ft = {}
      for fk, fv in pairs(v.fields) do
        local init = fv.init
        local override = v.fieldinitoverrides[fk]
        if override ~= nil then
          init = override
        end
        ft[fk] = {
          dynamicinit = fv.dynamicinit,
          getters = {},
          init = init,
        }
      end
      local mt = {}
      for mk, mv in pairs(v.methods) do
        mt[mk] = true
        for gk, gv in ipairs(mv.impl and mv.impl.getter or {}) do
          table.insert(ft[gv.name].getters, { index = gk, method = mk })
        end
      end
      for fk, fv in pairs(ft) do
        if fv.dynamicinit then
          ft[fk] = nil
        end
      end
      -- TODO remove these super duper field hacks
      ft.parent = nil
      if v.singleton then
        ft = {}
      elseif k == 'EditBox' then
        ft.shown.init = false
      end
      local st = {}
      for scripttype in pairs(allscripts) do
        st[scripttype] = not not (v.scripts and v.scripts[scripttype])
      end
      t[k] = {
        fields = ft,
        isa = v.isa,
        methods = mt,
        objtype = v.objectType or k,
        scripts = st,
        singleton = v.singleton,
        virtual = v.virtual,
      }
    end
    for _, product in ipairs(readyaml('data/products.yaml')) do
      for k in pairs(perproduct(product, 'uiobjects')) do
        if not t[k] then
          t[k] = { unsupported = true }
        end
      end
    end
    return 'UIObjectApis', t
  end,
}

local args = (function()
  local parser = require('argparse')()
  parser:argument('product')
  parser:argument('file')
  parser:argument('output')
  return parser:parse()
end)()
local function doit(k, p)
  if ptablemap[k] then
    local nn, tt = ptablemap[k](p)
    return '_G.WowlessData.' .. nn .. ' = ' .. require('pl.pretty').write(tt) .. '\n'
  elseif k == 'product' then
    return ('_G.WowlessData = { product = %q }'):format(p)
  elseif k == 'toc' then
    local tt = {}
    for kk in pairs(ptablemap) do
      table.insert(tt, kk .. '.lua')
    end
    table.sort(tt)
    table.insert(tt, 1, 'product.lua')
    table.insert(tt, 1, '## Interface: ' .. perproduct(p, 'build').tocversion)
    table.insert(tt, '')
    return table.concat(tt, '\n')
  else
    error('invalid file type ' .. k)
  end
end
local content = doit(args.file, args.product)
require('pl.file').write(args.output, content)
require('tools.util').writedeps(args.output, deps)
