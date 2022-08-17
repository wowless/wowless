local lfs = require('lfs')
local yaml = require('wowapi.yaml')

local function lazy(f)
  local cached
  return function()
    if not cached then
      cached = f()
    end
    return cached
  end
end

local apis = lazy(function()
  local t = {}
  for d in lfs.dir('data/api') do
    if d ~= '.' and d ~= '..' then
      local filename = ('data/api/%s'):format(d)
      local cfg = yaml.parseFile(filename)
      if not cfg.debug then
        t[cfg.name] = cfg
      end
    end
  end
  return t
end)

local function mapify(t)
  if t then
    local tt = {}
    for _, p in ipairs(t) do
      tt[p] = true
    end
    return tt
  end
end

local function stylua(s)
  local fn = os.tmpname()
  require('pl.file').write(fn, s)
  os.execute('stylua ' .. fn)
  local ret = require('pl.file').read(fn)
  os.remove(fn)
  return ret
end

local tablemap = {}

local ptablemap = {
  build = (function()
    local lazybuilds = lazy(function()
      return require('wowapi.yaml').parseFile('data/builds.yaml')
    end)
    return function(p)
      return 'Build', lazybuilds()[p]
    end
  end)(),
  cvars = (function()
    local lazycvars = lazy(function()
      return require('wowapi.yaml').parseFile('data/cvars.yaml')
    end)
    return function(p)
      local t = {}
      for k, v in pairs(lazycvars()) do
        t[k] = type(v) == 'string' and v or v[p]
      end
      return 'CVars', t
    end
  end)(),
  globalapis = function(p)
    local unavailableApis = {
      CreateForbiddenFrame = true,
      loadstring_untainted = true,
    }
    local t = {}
    for k, v in pairs(apis()) do
      if not k:find('%.') and (not v.products or mapify(v.products)[p]) then
        local vv = {
          alias = v.alias,
          nowrap = v.nowrap,
          secureCapsule = unavailableApis[k] and true,
          stdlib = v.stdlib,
        }
        t[k] = next(vv) and vv or true
      end
    end
    return 'GlobalApis', t
  end,
  globals = function(p)
    local cfg = require('wowapi.yaml').parseFile('data/globals/' .. p .. '.yaml')
    return 'Globals', cfg
  end,
  namespaceapis = function(p)
    local apiNamespaces = {}
    for k, v in pairs(apis()) do
      local dot = k:find('%.')
      if dot and (not v.products or mapify(v.products)[p]) then
        local name = k:sub(1, dot - 1)
        apiNamespaces[name] = apiNamespaces[name] or { methods = {} }
        apiNamespaces[name].methods[k:sub(dot + 1)] = v
      end
    end
    local unavailable = {
      -- These are grabbed by FrameXML and are unavailable by the time addons run.
      'C_AuthChallenge',
      'C_SecureTransfer',
      'C_StoreSecure',
      'C_WowTokenSecure',
    }
    for _, k in ipairs(unavailable) do
      assert(apiNamespaces[k])
      apiNamespaces[k] = nil
    end
    local t = {}
    for k, v in pairs(apiNamespaces) do
      local mt = {}
      for mk, mv in pairs(v.methods) do
        local tt = {
          stdlib = mv.stdlib,
        }
        mt[mk] = next(tt) and tt or true
      end
      t[k] = mt
    end
    return 'NamespaceApis', t
  end,
  uiobjectapis = function(p)
    local uiobjects = {}
    for d in lfs.dir('data/uiobjects') do
      if d ~= '.' and d ~= '..' then
        local filename = ('data/uiobjects/%s/%s.yaml'):format(d, d)
        local cfg = yaml.parseFile(filename)
        uiobjects[cfg.name] = cfg
      end
    end
    local inhrev = {}
    for _, cfg in pairs(uiobjects) do
      for _, inh in ipairs(cfg.inherits) do
        inhrev[inh] = inhrev[inh] or {}
        table.insert(inhrev[inh], cfg.name)
      end
    end
    local objTypes = {}
    for _, cfg in pairs(uiobjects) do
      objTypes[cfg.name] = cfg.objectType or cfg.name
    end
    local function fixup(cfg)
      for _, inhname in ipairs(cfg.inherits) do
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
    -- TODO figure out the right approach for these
    uiobjects.Minimap = nil
    uiobjects.WorldFrame = nil
    local t = {}
    for k, v in pairs(uiobjects) do
      if v.products and not mapify(v.products)[p] then
        t[k] = false
      else
        local mt = {}
        for mk, mv in pairs(v.methods) do
          if not mv.products or mapify(mv.products)[p] then
            mt[mk] = true
          end
        end
        t[k] = {
          frametype = not not frametypes[k],
          methods = mt,
          objtype = objTypes[k],
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
      for k in pairs(tablemap) do
        tt[k] = true
      end
      for k in pairs(ptablemap) do
        tt[k] = true
      end
      return tt
    end
  end)()
  local function style(ss)
    -- workaround tainted-lua issue with formatting %d
    ss = ss:gsub('DeprecatedCurrencyFlag = [-0-9]+', 'DeprecatedCurrencyFlag = 2147483648')
    return stylua(ss)
  end
  for k in pairs(files) do
    if tablemap[k] then
      local nn, tt = tablemap[k]()
      local ss = 'local _, G = ...\nG.' .. nn .. ' = ' .. require('pl.pretty').write(tt) .. '\n'
      t['addon/universal/Wowless/' .. k .. '.lua'] = style(ss)
    elseif ptablemap[k] then
      for _, p in ipairs(next(args.product) and args.product or require('wowless.util').productList()) do
        local nn, tt = ptablemap[k](p)
        local ss = '_G.WowlessData.' .. nn .. ' = ' .. require('pl.pretty').write(tt) .. '\n'
        t['addon/' .. p .. '/WowlessData/' .. k .. '.lua'] = style(ss)
      end
    elseif k == 'product' then
      for _, p in ipairs(next(args.product) and args.product or require('wowless.util').productList()) do
        local ss = ('_G.WowlessData = { product = %q }'):format(p)
        t['addon/' .. p .. '/WowlessData/' .. k .. '.lua'] = style(ss)
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
        t['addon/' .. p .. '/WowlessData/WowlessData.toc'] = content
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
