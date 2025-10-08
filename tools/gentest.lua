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
        payload = #v.payload,
        registerable = true,
      }
    end
    for _, product in ipairs(readyaml('data/products.yaml')) do
      for k in pairs(perproduct(product, 'events')) do
        if not t[k] then
          t[k] = {
            payload = -1,
            registerable = false,
          }
        end
      end
    end
    return 'Events', t
  end,
  globalapis = function(p)
    local impls = readyaml('data/impl.yaml')
    local function islua(api)
      local impl = impls[api.impl]
      if not impl or not impl.stdlib then
        return false
      end
      local g = assert(tpath(_G, strsplit('.', impl.stdlib)))
      return type(g) == 'function' and pcall(coroutine.create, g)
    end
    local config = perproduct(p, 'config')
    local t = {}
    for name, api in pairs(perproduct(p, 'apis')) do
      if not name:find('%.') then
        local vv = {
          islua = islua(api) or nil,
          overwritten = tpath(config, 'addon', 'overwritten_apis', name) and true,
          stdlib = api.impl and tpath(impls, api.impl, 'stdlib'),
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
  namespaceapis = function(p)
    local platform = dofile('build/cmake/runtime/platform.lua')
    local impls = readyaml('data/impl.yaml')
    local config = perproduct(p, 'config')
    local apiNamespaces = {}
    for k, api in pairs(perproduct(p, 'apis')) do
      local dot = k:find('%.')
      if dot and (not api.platform or api.platform == platform) then
        local name = k:sub(1, dot - 1)
        apiNamespaces[name] = apiNamespaces[name] or { methods = {} }
        apiNamespaces[name].methods[k:sub(dot + 1)] = api
      end
    end
    local t = {}
    for k, v in pairs(apiNamespaces) do
      local mt = {}
      for mk, mv in pairs(v.methods) do
        local tt = {
          overwritten = tpath(config, 'addon', 'overwritten_apis', k .. '.' .. mk) and true,
          stdlib = mv.impl and tpath(impls, mv.impl, 'stdlib'),
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
    local inhrev = {}
    for k, cfg in pairs(uiobjects) do
      for inh in pairs(cfg.inherits) do
        inhrev[inh] = inhrev[inh] or {}
        table.insert(inhrev[inh], k)
      end
      cfg.fieldinitoverrides = cfg.fieldinitoverrides or {}
    end
    local objTypes = {}
    for k, cfg in pairs(uiobjects) do
      objTypes[k] = cfg.objectType or k
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
      end
    end
    for _, cfg in pairs(uiobjects) do
      fixup(cfg)
    end
    local frametypes = {}
    local function addtype(ty)
      if not frametypes[ty] then
        frametypes[ty] = true
        for _, inh in ipairs(inhrev[ty] or {}) do
          addtype(inh)
        end
      end
    end
    addtype('Frame')
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
      if mt.HasScript then
        for scripttype in pairs(allscripts) do
          st[scripttype] = not not (v.scripts and v.scripts[scripttype])
        end
      end
      t[k] = {
        fields = ft,
        frametype = not not frametypes[k],
        methods = mt,
        objtype = objTypes[k],
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
    table.insert(tt, '')
    return table.concat(tt, '\n')
  else
    error('invalid file type ' .. k)
  end
end
local content = doit(args.file, args.product)
require('pl.file').write(args.output, content)
require('tools.util').writedeps(args.output, deps)
