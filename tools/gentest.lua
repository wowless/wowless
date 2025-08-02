local function mapify(t)
  if t then
    local tt = {}
    for _, p in ipairs(t) do
      tt[p] = true
    end
    return tt
  end
end

local function perproduct(p, f)
  return assert(dofile(('build/cmake/runtime/products/%s/%s.lua'):format(p, f)))
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
    for _, product in ipairs(dofile('build/cmake/runtime/products.lua')) do
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
    local impls = dofile('build/cmake/runtime/impl.lua')
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
    local r = require('pl.file').read
    local t = {}
    local deps = {}
    for _, api in pairs(perproduct(p, 'apis')) do
      if api.impl and not t[api.impl] then
        local f = 'data/test/' .. api.impl .. '.lua'
        local content = r(f)
        if content then
          t[api.impl] = content
          deps[f] = true
        end
      end
    end
    return 'ImplTests', t, deps
  end,
  namespaceapis = function(p)
    local impls = dofile('build/cmake/runtime/impl.lua')
    local config = perproduct(p, 'config')
    local apiNamespaces = {}
    for k, api in pairs(perproduct(p, 'apis')) do
      local dot = k:find('%.')
      if dot then
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
      ft.bottom = nil
      ft.height = nil
      ft.left = nil
      ft.parent = nil
      ft.top = nil
      ft.right = nil
      ft.width = nil
      if k == 'EditBox' then
        ft.shown.init = false
      elseif k == 'Font' then
        ft.name.init = 'WowlessFont1'
      elseif k == 'Minimap' then
        ft = {}
      end
      t[k] = {
        fields = ft,
        frametype = not not frametypes[k],
        methods = mt,
        objtype = objTypes[k],
        virtual = v.virtual,
      }
    end
    for _, product in ipairs(dofile('build/cmake/runtime/products.lua')) do
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
  parser:flag('-n --dryrun', 'do not write files')
  parser:option('-f --file', 'files to generate, default all'):count('*')
  parser:option('-p --product', 'products to generate, default all'):count('*')
  return parser:parse()
end)()
local filemap, alldeps = (function()
  local t = {}
  local deps = {}
  local files = (function()
    if next(args.file) then
      return mapify(args.file)
    else
      local tt = {}
      for k in pairs(ptablemap) do
        tt[k] = true
      end
      return tt
    end
  end)()
  for k in pairs(files) do
    if ptablemap[k] then
      for _, p in ipairs(next(args.product) and args.product or dofile('build/cmake/runtime/products.lua')) do
        local nn, tt, dd = ptablemap[k](p)
        local ss = '_G.WowlessData.' .. nn .. ' = ' .. require('pl.pretty').write(tt) .. '\n'
        local ff = 'build/products/' .. p .. '/WowlessData/' .. k .. '.lua'
        t[ff] = ss
        deps[ff] = dd
      end
    elseif k == 'product' then
      for _, p in ipairs(next(args.product) and args.product or dofile('build/cmake/runtime/products.lua')) do
        local ss = ('_G.WowlessData = { product = %q }'):format(p)
        t['build/products/' .. p .. '/WowlessData/' .. k .. '.lua'] = ss
      end
    elseif k == 'toc' then
      local tt = {}
      for kk in pairs(ptablemap) do
        table.insert(tt, kk .. '.lua')
      end
      table.sort(tt)
      table.insert(tt, 1, 'product.lua')
      table.insert(tt, '')
      local content = table.concat(tt, '\n')
      for _, p in ipairs(next(args.product) and args.product or dofile('build/cmake/runtime/products.lua')) do
        t['build/products/' .. p .. '/WowlessData/WowlessData.toc'] = content
      end
    else
      error('invalid file type ' .. k)
    end
  end
  return t, deps
end)()

if not args.dryrun then
  local w = require('pl.file').write
  for k, v in pairs(filemap) do
    w(k, v)
    os.execute('chmod a+x ' .. k)
  end
  for k, v in pairs(alldeps) do
    require('tools.util').writedeps(k, v)
  end
end
