local _, G = ...
local assertEquals = _G.assertEquals

local runtimeProduct = (function()
  local portal = _G.GetCVar('portal')
  local isPTR
  if portal == 'test' then
    isPTR = true
  elseif portal == '' then
    isPTR = false
  else
    error('invalid value for portal cvar: ' .. portal)
  end
  if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
    return isPTR and 'wow_classic_era_ptr' or 'wow_classic_era'
  elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
    local wrath = GetBuildInfo():sub(1, 1) == '3'
    return wrath and 'wow_classic_beta' or isPTR and 'wow_classic_ptr' or 'wow_classic'
  elseif WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    local dragon = GetBuildInfo():sub(1, 1) ~= '9'
    return dragon and 'wow_beta' or isPTR and 'wowt' or 'wow'
  else
    error('invalid product')
  end
end)()

do
  local print = print or _G.__wowless.dump
  print('Wowless thinks this is ' .. runtimeProduct .. '.')
end

local function tget(t, s)
  local dot = s:find('%.')
  if dot then
    local p = s:sub(1, dot - 1)
    return t[p] and t[p][s:sub(dot + 1)]
  else
    return t[s]
  end
end

-- Do this early to avoid issues with deferred cvar creation.
local cvarDefaults = (function()
  local t = {}
  for _, command in ipairs(_G.C_Console.GetAllCommands()) do
    local name = command.command
    t[name] = _G.C_CVar.GetCVarDefault(name)
  end
  return t
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

  local function apiNamespaces()
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
              local ty = type(tget(_G, mcfg.stdlib))
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
  end

  local function build()
    local b = G.Builds[runtimeProduct]
    assert(b, 'no build')
    return {
      GetBuildInfo = function()
        G.check4(b.version, b.build, b.date, b.tocversion, GetBuildInfo())
      end,
      IsDebugBuild = function()
        G.check1(false, _G.IsDebugBuild())
      end,
      IsPublicBuild = function()
        G.check1(true, _G.IsPublicBuild())
      end,
      IsTestBuild = function()
        G.check1(b.test, IsTestBuild())
      end,
    }
  end

  local function cvars()
    local tests = {}
    for name, cfg in pairs(G.CVars) do
      tests[name] = function()
        assertEquals(type(cfg) == 'string' and cfg or cfg[runtimeProduct], cvarDefaults[name])
      end
    end
    local toskip = {
      TTSUseCharacterSettings = true,
    }
    for k, v in pairs(cvarDefaults) do
      if not tests[k] and not toskip[k] then
        tests[k] = function()
          error(format('missing cvar %q with default %q', k, v))
        end
      end
    end
    return tests
  end

  local function globalApis()
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
          assertEquals(func, assert(tget(_G, cfg.alias)))
        elseif cfg.stdlib then
          local ty = type(tget(_G, cfg.stdlib))
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
  end

  local function globals()
    local data = G['Globals_' .. runtimeProduct]
    if _G.SecureCapsuleGet ~= nil then -- addon_spec hack
      -- TODO grab these a la theflatdumper
      local toskip = {
        'BattlepayBannerType',
        'BattlepayCardType',
        'BattlepayDisplayFlag',
        'BattlepayGroupDisplayType',
        'BattlepayProductDecorator',
        'BattlepayProductGroupFlag',
        'PurchaseEligibility',
        'StoreError',
        'VasError',
        'VasServiceType',
      }
      for _, v in ipairs(toskip) do
        data.Enum[v] = nil
      end
    end
    local tests = {}
    for k, v in pairs(data) do
      tests[k] = function()
        return G.assertRecursivelyEqual(v, _G[k])
      end
    end
    local genums = {}
    for k, v in pairs(_G) do
      if k:sub(1, 7) == 'NUM_LE_' then
        genums[k:sub(5, -2)] = v
        tests[k] = tests[k] or function()
          error('missing, has value ' .. v)
        end
      end
    end
    for k, v in pairs(_G) do
      for gk in pairs(genums) do
        if k:sub(1, #gk) == gk then
          tests[k] = tests[k] or function()
            error('missing, has value ' .. v)
          end
        end
      end
    end
    return tests
  end

  local function productTest()
    if _G.__wowless then
      assertEquals(_G.__wowless.product, runtimeProduct)
    end
  end

  local function uiobjects()
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
                  assertEquals('nil', type(__index[mname]), 'product disabled')
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
  end

  return {
    apiNamespaces = apiNamespaces,
    build = build,
    cvars = cvars,
    globalApis = globalApis,
    globals = globals,
    product = productTest,
    uiobjects = uiobjects,
  }
end
