local plsub = require('pl.template').substitute
local sorted = require('pl.tablex').sort

local apis = {}
local uiobjects = {}
do
  local lfs = require('lfs')
  local yaml = require('wowapi.yaml')
  for d in lfs.dir('data/api') do
    if d ~= '.' and d ~= '..' then
      local filename = ('data/api/%s'):format(d)
      local cfg = yaml.parseFile(filename)
      if not cfg.debug then
        apis[cfg.name] = cfg
      end
    end
  end
  for d in lfs.dir('data/uiobjects') do
    if d ~= '.' and d ~= '..' then
      local filename = ('data/uiobjects/%s/%s.yaml'):format(d, d)
      local cfg = yaml.parseFile(filename)
      uiobjects[cfg.name] = cfg
    end
  end
end

local inhrev = {}
for _, cfg in pairs(uiobjects) do
  for _, inh in ipairs(cfg.inherits) do
    inhrev[inh] = inhrev[inh] or {}
    table.insert(inhrev[inh], cfg.name)
  end
end

local unavailableApis = {
  CreateForbiddenFrame = true,
  loadstring_untainted = true,
}

local objTypes = {}
for _, cfg in pairs(uiobjects) do
  objTypes[cfg.name] = cfg.objectType or cfg.name
end

do
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
end

local frametypes = {}
do
  local function addtype(ty)
    if not frametypes[ty] then
      frametypes[ty] = true
      for _, inh in ipairs(inhrev[ty] or {}) do
        addtype(inh)
      end
    end
  end
  addtype('Frame')
end

local apiNamespaces = {}
do
  for k, v in pairs(apis) do
    local p = k:find('%.')
    if p then
      local name = k:sub(1, p - 1)
      apiNamespaces[name] = apiNamespaces[name] or { methods = {} }
      apiNamespaces[name].methods[k:sub(p + 1)] = v
    end
  end
  for _, v in pairs(apiNamespaces) do
    local allProducts = require('wowless.util').productList()
    local products = {}
    for _, m in pairs(v.methods) do
      for _, product in ipairs(m.products or allProducts) do
        products[product] = true
      end
    end
    local plist = {}
    for f in pairs(products) do
      table.insert(plist, f)
    end
    assert(next(plist))
    v.products = #plist ~= #allProducts and plist or nil
    for _, m in pairs(v.methods) do
      if m.products and #m.products == #plist then
        m.products = nil
      end
    end
  end
  local unavailable = {
    -- These are grabbed by FrameXML and are unavailable by the time addons run.
    'C_AuthChallenge',
    'C_SecureTransfer',
    'C_StoreSecure',
    'C_WowTokenSecure',
    -- This is documented but does not actually seem to exist.
    'C_ConfigurationWarnings',
  }
  for _, k in ipairs(unavailable) do
    assert(apiNamespaces[k])
    apiNamespaces[k] = nil
  end
end

local function badproduct(products)
  return 'badProduct(\'' .. table.concat(products, ',') .. '\')'
end

-- TODO figure out the right approach for these
uiobjects.Minimap = nil
uiobjects.WorldFrame = nil

local globalApis = (function()
  local t = {}
  table.insert(t, 'local _, G = ...')
  table.insert(t, 'G.GlobalApis = {')
  for k, v in sorted(apis) do
    if not k:find('%.') then
      table.insert(t, '') -- to be filled in later
      local idx = #t
      if v.alias then
        table.insert(t, '    alias = { _G.' .. v.alias .. ' },')
      end
      if v.nowrap then
        table.insert(t, '    nowrap = true,')
      end
      if v.products then
        table.sort(v.products)
        table.insert(t, '    products = {')
        for _, p in ipairs(v.products) do
          table.insert(t, '      ' .. p .. ' = true,')
        end
        table.insert(t, '    },')
      end
      if unavailableApis[k] then
        table.insert(t, '    secureCapsule = true,')
      end
      if v.stdlib then
        table.insert(t, '    stdlib = { _G.' .. v.stdlib .. ' },')
      end
      if t[idx + 1] then
        t[idx] = '  ' .. k .. ' = {'
        table.insert(t, '  },')
      else
        t[idx] = '  ' .. k .. ' = true,'
      end
    end
  end
  table.insert(t, '}')
  table.insert(t, '')
  return table.concat(t, '\n')
end)()

local namespaceApis = (function()
  local t = {}
  table.insert(t, 'local _, G = ...')
  table.insert(t, 'G.NamespaceApis = {')
  for k, v in sorted(apiNamespaces) do
    table.insert(t, '  ' .. k .. ' = {')
    table.insert(t, '    methods = {')
    for mk, mv in sorted(v.methods) do
      table.insert(t, '') -- to be filled in later
      local idx = #t
      if mv.products then
        table.sort(mv.products)
        table.insert(t, '        products = {')
        for _, p in ipairs(mv.products) do
          table.insert(t, '          ' .. p .. ' = true,')
        end
        table.insert(t, '        },')
      end
      if mv.stdlib then
        table.insert(t, '        stdlib = { _G.' .. mv.stdlib .. ' },')
      end
      if t[idx + 1] then
        t[idx] = '      ' .. mk .. ' = {'
        table.insert(t, '      },')
      else
        t[idx] = '      ' .. mk .. ' = true,'
      end
    end
    table.insert(t, '    },')
    if v.products then
      table.sort(v.products)
      table.insert(t, '    products = {')
      for _, p in ipairs(v.products) do
        table.insert(t, '      ' .. p .. ' = true,')
      end
      table.insert(t, '    },')
    end
    table.insert(t, '  },')
  end
  table.insert(t, '}')
  table.insert(t, '')
  return table.concat(t, '\n')
end)()

local uiobjectApis = (function()
  local t = {}
  table.insert(t, 'local _, G = ...')
  table.insert(t, 'G.UIObjectApis = {')
  for k, v in sorted(uiobjects) do
    table.insert(t, '  ' .. k .. ' = {')
    table.insert(t, '    frametype = ' .. tostring(not not frametypes[k]) .. ',')
    table.insert(t, '    methods = {')
    for mk, mv in sorted(v.methods) do
      table.insert(t, '') -- to be filled in later
      local idx = #t
      if mv.products and (not v.products or #mv.products < #v.products) then
        table.sort(mv.products)
        table.insert(t, '        products = {')
        for _, p in ipairs(mv.products) do
          table.insert(t, '          ' .. p .. ' = true,')
        end
        table.insert(t, '        },')
      end
      if t[idx + 1] then
        t[idx] = '      ' .. mk .. ' = {'
        table.insert(t, '      },')
      else
        t[idx] = '      ' .. mk .. ' = true,'
      end
    end
    table.insert(t, '    },')
    table.insert(t, '    objtype = \'' .. objTypes[k] .. '\',')
    if v.products then
      table.sort(v.products)
      table.insert(t, '    products = {')
      for _, p in ipairs(v.products) do
        table.insert(t, '      ' .. p .. ' = true,')
      end
      table.insert(t, '    },')
    end
    table.insert(t, '  },')
  end
  table.insert(t, '}')
  table.insert(t, '')
  return table.concat(t, '\n')
end)()

local text = assert(plsub(
  [[
local _, G = ...
local assertEquals = _G.assertEquals
local runtimeProduct = (function()
  if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
    return IsTestBuild() and 'wow_classic_era_ptr' or 'wow_classic_era'
  elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
    local wrath = GetBuildInfo():sub(1, 1) == '3'
    return wrath and 'wow_classic_beta' or IsTestBuild() and 'wow_classic_ptr' or 'wow_classic'
  elseif WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    local dragon = GetBuildInfo():sub(1, 1) ~= '9'
    return dragon and 'wow_beta' or IsTestBuild() and 'wowt' or 'wow'
  else
    error('invalid product')
  end
end)()
function G.GeneratedTests()
  local cfuncs = {}
  local function checkFunc(func, isLua)
    assertEquals('function', type(func))
    return {
      getfenv = function()
        assertEquals(_G, getfenv(func))
      end,
      impltype = function()
        assertEquals(
          isLua,
          pcall(function()
            coroutine.create(func)
          end)
        )
      end,
      unique = not isLua and function()
        assertEquals(nil, cfuncs[func])
        cfuncs[func] = true
      end or nil,
    }
  end
  local function checkCFunc(func)
    return checkFunc(func, false)
  end
  local function checkLuaFunc(func)
    return checkFunc(func, true)
  end
  local function checkNotCFunc(func)
    if func ~= nil and not cfuncs[func] then
      return checkLuaFunc(func)
    end
  end
  return {
    apiNamespaces = function()
      local function mkTests(ns, tests)
        for k, v in pairs(ns) do
          -- Anything left over must be a FrameXML-defined function.
          if not tests[k] then
            tests['~' .. k] = function()
              if not cfuncs[v] then
                return checkLuaFunc(v)
              end
            end
          end
        end
        return tests
      end
      local tests = {}
      local empty = {}
      for name, ncfg in pairs(G.NamespaceApis) do
        tests[name] = function()
          local ns = _G[name]
          if ncfg.products and not ncfg.products[runtimeProduct] then
            assertEquals('nil', type(ns))
            return
          end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          local mtests = {}
          for mname, mcfg in pairs(ncfg.methods) do
            mcfg = mcfg == true and empty or mcfg
            mtests[mname] = function()
              local func = ns[mname]
              if mcfg.products and not mcfg.products[runtimeProduct] then
                return checkNotCFunc(func)
              end
              if mcfg.stdlib then
                local ty = type(mcfg.stdlib[1])
                if ty == 'function' then
                  return checkCFunc(func)
                else
                  assertEquals(ty, type(func))
                end
              else
                return checkCFunc(func)
              end
            end
          end
          return mkTests(ns, mtests)
        end
      end
      return tests
    end,
    globalApis = function()
      local tests = {}
      local empty = {}
      for name, cfg in pairs(G.GlobalApis) do
        cfg = cfg == true and empty or cfg
        tests[name] = function()
          local func = _G[name]
          if cfg.products and not cfg.products[runtimeProduct] then
            return checkNotCFunc(func)
          end
          if cfg.secureCapsule then
            assertEquals(_G.SecureCapsuleGet == nil, func ~= nil) -- addon_spec hack
          elseif cfg.alias then
            assertEquals(func, assert(cfg.alias[1]))
          elseif cfg.stdlib then
            local ty = type(cfg.stdlib[1])
            if ty == 'function' then
              return checkCFunc(func)
            else
              assertEquals(ty, type(func))
            end
          elseif cfg.nowrap then
            return checkLuaFunc(func)
          else
            return checkCFunc(func)
          end
        end
      end
      local ptrhooked = { -- TODO test these better
        FauxScrollFrame_Update = true,
        QuestLog_Update = true,
        QuestMapLogTitleButton_OnEnter = true,
        SetItemRef = true,
      }
      for k, v in pairs(_G) do
        if type(v) == 'function' and not tests[k] and not ptrhooked[k] then
          tests['~' .. k] = function()
            if not cfuncs[v] then
              return checkLuaFunc(v)
            end
          end
        end
      end
      return tests
    end,
    uiobjects = function()
      local function assertCreateFrame(ty)
        local function process(...)
          assertEquals(1, select('#', ...))
          local frame = ...
          assert(type(frame) == 'table')
          return frame
        end
        return process(CreateFrame(ty))
      end
      local function assertCreateFrameFails(ty)
        local success, err = pcall(function()
          CreateFrame(ty)
        end)
        assert(not success)
        local expectedErr = 'CreateFrame: Unknown frame type \'' .. ty .. '\''
        assertEquals(expectedErr, err:sub(err:len() - expectedErr:len() + 1))
      end
      local GetObjectType = CreateFrame('Frame').GetObjectType
      local indexes = {}
      local function mkTests(objectTypeName, factory, tests)
        local obj = factory()
        local obj2 = factory()
        if objectTypeName == 'EditBox' then
          obj:Hide() -- captures input focus otherwise
          obj2:Hide() -- captures input focus otherwise
        end
        assert(obj ~= obj2)
        assertEquals(objectTypeName, GetObjectType(obj))
        local mt = getmetatable(obj)
        assert(mt == getmetatable(obj2))
        if objectTypeName ~= 'FogOfWarFrame' or WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
          assert(mt ~= nil)
          assert(getmetatable(mt) == nil)
          local mtk, __index = next(mt)
          assertEquals('__index', mtk)
          assertEquals('table', type(__index))
          assertEquals(nil, next(mt, mtk))
          assertEquals(nil, getmetatable(__index))
          assertEquals(nil, indexes[__index])
          indexes[__index] = true
          return {
            contents = function()
              local udk, udv = next(obj)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(obj, udk) == nil)
            end,
            methods = function()
              local t = tests(__index)
              for k in pairs(__index) do
                t[k] = t[k] or function()
                  error('missing')
                end
              end
              return t
            end,
          }
        end
      end
      local tests = {}
      local empty = {}
      for name, cfg in pairs(G.UIObjectApis) do
        local function factory()
          if name == 'Animation' then
            return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation()
          elseif name == 'FontString' then
            return CreateFrame('Frame'):CreateFontString()
          elseif name == 'Texture' then
            return CreateFrame('Frame'):CreateTexture()
          else
            return assertCreateFrame(name)
          end
        end
        tests[name] = function()
          if not cfg.frametype or cfg.products and not cfg.products[runtimeProduct] then
            assertCreateFrameFails(name)
          else
            return mkTests(cfg.objtype, factory, function(__index)
              local mtests = {}
              for mname, mcfg in pairs(cfg.methods) do
                mtests[mname] = function()
                  mcfg = mcfg == true and empty or mcfg
                  if mcfg.products and not mcfg.products[runtimeProduct] then
                    assertEquals('nil', type(__index[mname]))
                  elseif name ~= 'Animation' or mname ~= 'GetSourceLocation' then --FIXME
                    return checkCFunc(__index[mname])
                  end
                end
              end
              return mtests
            end)
          end
        end
      end
      return tests
    end,
  }
end
]],
  {
    _escape = '>',
    _G = _G,
    apiNamespaces = apiNamespaces,
    apis = apis,
    badproduct = badproduct,
    frametypes = frametypes,
    next = next,
    objTypes = objTypes,
    sorted = sorted,
    tget = require('wowless.util').tget,
    type = type,
    uiobjects = uiobjects,
    unavailableApis = unavailableApis,
  }
))

local filemap = {
  ['addon/Wowless/generated.lua'] = text,
  ['addon/Wowless/globalapis.lua'] = globalApis,
  ['addon/Wowless/namespaceapis.lua'] = namespaceApis,
  ['addon/Wowless/uiobjectapis.lua'] = uiobjectApis,
}

-- Hack so test doesn't have side effects.
if select('#', ...) == 0 then
  local w = require('pl.file').write
  for k, v in pairs(filemap) do
    w(k, v)
  end
else
  return filemap
end
