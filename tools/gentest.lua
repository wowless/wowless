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
  return assert(require(('build.data.products.%s.%s'):format(p, f)))
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
    return 'Config', perproduct(p, 'config').addon or {}
  end,
  cvars = function(p)
    return 'CVars', perproduct(p, 'cvars')
  end,
  events = function(p)
    local t = {}
    for k, v in pairs(perproduct(p, 'events')) do
      t[k] = {
        payload = v.payload and #v.payload or -1,
        registerable = true,
      }
    end
    for _, product in ipairs(require('wowless.util').productList()) do
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
    local t = {}
    for name, api in pairs(perproduct(p, 'apis')) do
      if not name:find('%.') and not api.debug then
        local vv = {
          alias = api.alias,
          nowrap = api.nowrap,
          stdlib = api.stdlib,
        }
        t[name] = next(vv) and vv or true
      end
    end
    return 'GlobalApis', t
  end,
  globals = function(p)
    return 'Globals', perproduct(p, 'globals')
  end,
  namespaceapis = function(p)
    local config = perproduct(p, 'config')
    local apiNamespaces = {}
    for k, api in pairs(perproduct(p, 'apis')) do
      local dot = k:find('%.')
      if dot and not api.debug then
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
          alias = mv.alias,
          overwritten = tpath(config, 'addon', 'overwritten_apis', k .. '.' .. mk) and true,
          stdlib = mv.stdlib,
        }
        mt[mk] = next(tt) and tt or true
      end
      t[k] = mt
    end
    return 'NamespaceApis', t
  end,
  uiobjectapis = function(p)
    local config = perproduct(p, 'config')
    local uiobjects = perproduct(p, 'uiobjects')
    local inhrev = {}
    for k, cfg in pairs(uiobjects) do
      for inh in pairs(cfg.inherits) do
        inhrev[inh] = inhrev[inh] or {}
        table.insert(inhrev[inh], k)
      end
    end
    local objTypes = {}
    for k, cfg in pairs(uiobjects) do
      objTypes[k] = cfg.objectType or k
    end
    local function fixup(cfg)
      for inhname in pairs(cfg.inherits) do
        local inh = uiobjects[inhname]
        fixup(inh)
        for n, m in pairs(inh.methods) do
          cfg.methods[n] = m
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
      if not tpath(config, 'addon', 'skipped_uiobjects', k) then
        local mt = {}
        for mk in pairs(v.methods) do
          mt[mk] = true
        end
        t[k] = {
          frametype = not not frametypes[k],
          methods = mt,
          objtype = objTypes[k],
          virtual = v.virtual,
          zombie = v.zombie,
        }
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
local filemap = (function()
  local t = {}
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
  local function style(ss)
    -- workaround elune issue with formatting %d
    return ss:gsub('DeprecatedCurrencyFlag = [-0-9]+', 'DeprecatedCurrencyFlag = 2147483648')
  end
  for k in pairs(files) do
    if ptablemap[k] then
      for _, p in ipairs(next(args.product) and args.product or require('wowless.util').productList()) do
        local nn, tt = ptablemap[k](p)
        local ss = '_G.WowlessData.' .. nn .. ' = ' .. require('pl.pretty').write(tt) .. '\n'
        t['build/products/' .. p .. '/WowlessData/' .. k .. '.lua'] = style(ss)
      end
    elseif k == 'product' then
      for _, p in ipairs(next(args.product) and args.product or require('wowless.util').productList()) do
        local ss = ('_G.WowlessData = { product = %q }'):format(p)
        t['build/products/' .. p .. '/WowlessData/' .. k .. '.lua'] = style(ss)
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
      for _, p in ipairs(next(args.product) and args.product or require('wowless.util').productList()) do
        t['build/products/' .. p .. '/WowlessData/WowlessData.toc'] = content
      end
    else
      error('invalid file type ' .. k)
    end
  end
  return t
end)()

if not args.dryrun then
  local w = require('pl.file').write
  for k, v in pairs(filemap) do
    w(k, v)
    os.execute('chmod a+x ' .. k)
  end
end
