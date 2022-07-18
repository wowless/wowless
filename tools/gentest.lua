local plsub = require('pl.template').substitute

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
local function badProduct(s)
  for p in string.gmatch(s, '[^,]+') do
    if p == runtimeProduct then
      return false
    end
  end
  return true
end
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
      return {
> for k, v in sorted(apiNamespaces) do
        $(k) = function()
          local ns = _G.$(k)
> if v.products then
          if $(badproduct(v.products)) then
            assertEquals('nil', type(ns))
            return
          end
> end
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          return mkTests(ns, {
> for mname, method in sorted(v.methods) do
            $(mname) = function()
> if method.products and (not v.products or #method.products < #v.products) then
              if $(badproduct(method.products)) then
                return checkNotCFunc(ns.$(mname))
              end
> end
> if method.stdlib then
>   local ty = type(tget(_G, method.stdlib))
>   if ty == 'function' then
              return checkCFunc(ns.$(mname))
>   else
              assertEquals('$(ty)', type(ns.$(mname)))
>   end
> else
              return checkCFunc(ns.$(mname))
> end
            end,
> end
          })
        end,
> end
      }
    end,
    globalApis = function()
      local tests = {
> for k, v in sorted(apis) do
> if not k:find('%.') then
        $(k) = function()
> if v.products then
          if $(badproduct(v.products)) then
            return checkNotCFunc(_G.$(k))
          end
> end
> if unavailableApis[k] then
          assertEquals(_G.SecureCapsuleGet == nil, _G.$(k) ~= nil) -- addon_spec hack
> elseif v.alias then
          assertEquals(_G.$(k), _G.$(v.alias))
> elseif v.stdlib then
>   local ty = type(tget(_G, v.stdlib))
>   if ty == 'function' then
          return checkCFunc(_G.$(k))
>   else
          assertEquals('$(ty)', type(_G.$(k)))
>   end
> elseif v.nowrap then
          return checkLuaFunc(_G.$(k))
> else
          return checkCFunc(_G.$(k))
> end
        end,
> end
> end
      }
      local ptrhooked = { -- TODO test these better
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
      return {
> for k, v in sorted(uiobjects) do
        $(k) = function()
> if frametypes[k] and v.products then
          if $(badproduct(v.products)) then
            assertCreateFrameFails('$(k)')
            return
          end
> end
> if frametypes[k] or k == 'Animation' or k == 'FontString' or k == 'Texture' then
          local function factory()
> if k == 'Animation' then
            return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation()
> elseif k == 'FontString' then
            return CreateFrame('Frame'):CreateFontString()
> elseif k == 'Texture' then
            return CreateFrame('Frame'):CreateTexture()
> else
            return assertCreateFrame('$(k)')
> end
          end
          return mkTests('$(objTypes[k])', factory, function(__index)
            return {
> for mname, method in sorted(v.methods) do
              $(mname) = function()
> if method.products then
                if $(badproduct(method.products)) then
                  assertEquals('nil', type(__index.$(mname)))
                  return
                end
> end
> if k ~= 'Animation' or mname ~= 'GetSourceLocation' then --FIXME
                return checkCFunc(__index.$(mname))
> end
              end,
> end
            }
          end)
> else
          assertCreateFrameFails('$(k)')
> end
        end,
> end
      }
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
    sorted = require('pl.tablex').sort,
    tget = require('wowless.util').tget,
    type = type,
    uiobjects = uiobjects,
    unavailableApis = unavailableApis,
  }
))

-- Hack so test doesn't have side effects.
if select('#', ...) == 0 then
  require('pl.file').write('addon/Wowless/generated.lua', text)
end
return text
