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

local function mapify(t)
  if t then
    local tt = {}
    for _, p in ipairs(t) do
      tt[p] = true
    end
    return tt
  end
end

local function hasproduct(t, p)
  return not t.products or mapify(t.products)[p]
end

local function stylua(s)
  local fn = os.tmpname()
  require('pl.file').write(fn, s)
  os.execute('stylua ' .. fn)
  local ret = require('pl.file').read(fn)
  os.remove(fn)
  return ret
end

local function perproduct(p, f)
  return (require('wowapi.yaml').parseFile(('data/products/%s/%s.yaml'):format(p, f)))
end

local ptablemap = {
  build = function(p)
    return 'Build', perproduct(p, 'build')
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
      for inh, t in pairs(cfg.inherits) do
        if hasproduct(t, p) then
          inhrev[inh] = inhrev[inh] or {}
          table.insert(inhrev[inh], cfg.name)
        end
      end
    end
    local objTypes = {}
    for _, cfg in pairs(uiobjects) do
      objTypes[cfg.name] = cfg.objectType or cfg.name
    end
    local function fixup(cfg)
      for inhname, t in pairs(cfg.inherits) do
        if hasproduct(t, p) then
          local inh = uiobjects[inhname]
          fixup(inh)
          for n, m in pairs(inh.methods) do
            cfg.methods[n] = m
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
    -- TODO figure out the right approach for these
    uiobjects.Minimap = nil
    uiobjects.WorldFrame = nil
    local t = {}
    for k, v in pairs(uiobjects) do
      if not hasproduct(v, p) then
        t[k] = false
      else
        local mt = {}
        for mk, mv in pairs(v.methods) do
          if hasproduct(mv, p) then
            mt[mk] = true
          end
        end
        t[k] = {
          frametype = not not frametypes[k],
          methods = mt,
          objtype = objTypes[k],
          virtual = v.virtual,
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
    ss = ss:gsub('DeprecatedCurrencyFlag = [-0-9]+', 'DeprecatedCurrencyFlag = 2147483648')
    return stylua(ss)
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
