local _, G = ...
local assertEquals = _G.assertEquals

local capsuleEnv = _G.SimpleCheckout and getfenv(_G.SimpleCheckout.OnLoad) or {}

assert(_G.WowlessData, 'missing WowlessData')
local runtimeProduct = assert(_G.WowlessData.product, 'missing product')

local function tget(t, s)
  local dot = s:find('%.')
  if dot then
    local p = s:sub(1, dot - 1)
    return t[p] and t[p][s:sub(dot + 1)]
  else
    return t[s]
  end
end

function G.GeneratedTests()
  local cfuncs = {}

  local function checkFunc(func, isLua, env)
    assertEquals('function', type(func))
    return {
      getfenv = function()
        assertEquals(env or _G, getfenv(func))
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

  local function checkCFunc(func, env)
    return checkFunc(func, false, env)
  end

  local function checkLuaFunc(func, env)
    return checkFunc(func, true, env)
  end

  local function checkNotCFunc(func, env)
    if func ~= nil and not cfuncs[func] then
      return checkLuaFunc(func, env)
    end
  end

  local function apiNamespaces()
    local function mkTests(ns, tests)
      for k, v in pairs(ns) do
        -- Anything left over must be a FrameXML-defined function.
        if not tests[k] then
          tests['~' .. k] = function()
            return checkNotCFunc(v)
          end
        end
      end
      return tests
    end
    local tests = {}
    local empty = {}
    for name, ncfg in pairs(_G.WowlessData.NamespaceApis) do
      tests[name] = function()
        local ns = _G[name]
        assertEquals('table', type(ns))
        assert(getmetatable(ns) == nil)
        local mtests = {}
        for mname, mcfg in pairs(ncfg) do
          mcfg = mcfg == true and empty or mcfg
          mtests[mname] = function()
            local func = ns[mname]
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
    local b = _G.WowlessData.Build
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
    -- Do this early to avoid issues with deferred cvar creation.
    local cvarDefaults = (function()
      local t = {}
      for _, command in ipairs(_G.C_Console.GetAllCommands()) do
        local name = command.command
        if name:sub(1, 6) ~= 'CACHE-' then
          t[name] = _G.C_CVar.GetCVarDefault(name)
        end
      end
      return t
    end)()
    local tests = {}
    local toskipin = {
      mouseSpeed = true, -- varies based on host?
      RenderScale = true, -- varies based on host?
    }
    for name in pairs(toskipin) do
      tests[name] = function() end
    end
    for name, value in pairs(_G.WowlessData.CVars) do
      if not tests[name] then
        tests[name] = function()
          assertEquals(value, cvarDefaults[name])
        end
      end
    end
    local toskipout = {
      PraiseTheSun = true, -- set in FrameXML
      TTSUseCharacterSettings = true,
    }
    for k, v in pairs(cvarDefaults) do
      if not tests[k] and not toskipout[k] then
        tests[k] = function()
          error(format('missing cvar %q with default %q', k, v))
        end
      end
    end
    return tests
  end

  local function events()
    local tests = {}
    local frame = CreateFrame('Frame')
    for k, v in pairs(_G.WowlessData.Events) do
      tests[k] = function()
        assertEquals(
          v,
          pcall(function()
            frame:RegisterEvent(k)
          end)
        )
      end
    end
    return tests
  end

  local function globalApis()
    local tests = {}
    local empty = {}
    for name, cfg in pairs(_G.WowlessData.GlobalApis) do
      cfg = cfg == true and empty or cfg
      tests[name] = function()
        local func = _G[name] or capsuleEnv[name]
        if cfg.alias then
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
    local toskip = { -- TODO test these better
      -- PTR hooked
      FauxScrollFrame_Update = true,
      QuestLog_Update = true,
      QuestMapLogTitleButton_OnEnter = true,
      SetItemRef = true,
      -- SecureCapsule-grabbed Lua functions defined outside capsule
      CreateFromSecureMixins = true,
      SecureMixin = true,
    }
    local function checkEnv(env)
      for k, v in pairs(env) do
        if type(v) == 'function' and not tests[k] and not tests['~' .. k] and not toskip[k] then
          tests['~' .. k] = function()
            return checkNotCFunc(v, env)
          end
        end
      end
    end
    checkEnv(_G)
    checkEnv(capsuleEnv)
    return tests
  end

  local function globals()
    local data = _G.WowlessData.Globals
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
        genums[k:sub(5, -2)] = true
        tests[k] = tests[k] or function()
          error('missing, has value ' .. v)
        end
      end
    end
    -- LE_EXPANSION works differently for some reason
    assert(genums.LE_EXPANSION == nil)
    genums.LE_EXPANSION = true
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
    local indexes = {}
    local function mkTests(objectTypeName, factory, tests)
      local obj = assert(factory(), 'factory failed')
      local obj2 = assert(factory(), 'factory failed')
      if objectTypeName == 'EditBox' then
        obj:Hide() -- captures input focus otherwise
        obj2:Hide() -- captures input focus otherwise
      end
      assert(obj ~= obj2)
      local mt = getmetatable(obj)
      assert(mt == getmetatable(obj2))
      if objectTypeName == 'FogOfWarFrame' and WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
        assert(mt == nil)
        assertEquals(objectTypeName, CreateFrame('Frame').GetObjectType(obj))
      else
        assert(mt ~= nil)
        assertEquals(objectTypeName, obj:GetObjectType())
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
    local factories = {
      Actor = function()
        return CreateFrame('ModelScene'):CreateActor()
      end,
      Alpha = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Alpha')
      end,
      Animation = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation()
      end,
      AnimationGroup = function()
        return CreateFrame('Frame'):CreateAnimationGroup()
      end,
      ControlPoint = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Path'):CreateControlPoint()
      end,
      Font = (function()
        local count = 0
        return function()
          count = count + 1
          return CreateFont('WowlessFont' .. count)
        end
      end)(),
      FontString = function()
        return CreateFrame('Frame'):CreateFontString()
      end,
      Line = function()
        return CreateFrame('Frame'):CreateLine()
      end,
      LineScale = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('LineScale')
      end,
      LineTranslation = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('LineTranslation')
      end,
      MaskTexture = function()
        return CreateFrame('Frame'):CreateMaskTexture()
      end,
      Path = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Path')
      end,
      Rotation = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Rotation')
      end,
      Scale = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Scale')
      end,
      Texture = function()
        return CreateFrame('Frame'):CreateTexture()
      end,
      Translation = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Translation')
      end,
    }
    local exceptions = { -- TODO remove need for this
      Actor = {
        GetScript = true,
        HasScript = true,
        HookScript = true,
        SetParent = true,
        SetScript = true,
      },
      AnimationGroup = { SetParent = true },
      Line = {
        AddMaskTexture = true,
        AdjustPointsOffset = true,
        ClearPointByName = true,
        ClearPointsOffset = true,
        GetMaskTexture = true,
        GetNumMaskTextures = true,
        GetNumPoints = true,
        GetPoint = true,
        GetPointByName = true,
        RemoveMaskTexture = true,
        SetAllPoints = true,
        SetHeight = true,
        SetPoint = true,
        SetSize = true,
        SetWidth = true,
      },
      MaskTexture = {
        AddMaskTexture = true,
        GetMaskTexture = true,
        GetNumMaskTextures = true,
        RemoveMaskTexture = true,
      },
    }
    local warners = {
      FontString = true,
      Line = true,
      Texture = true,
    }
    local tests = {}
    for name, cfg in pairs(_G.WowlessData.UIObjectApis) do
      tests[name] = function()
        local exc = exceptions[name]
        if cfg == false then
          assertCreateFrameFails(name)
          table.insert(G.ExpectedLuaWarnings, {
            warnText = 'Unknown frame type: ' .. name,
            warnType = 0,
          })
        else
          if not cfg.frametype then
            assertCreateFrameFails(name)
            if warners[name] then
              table.insert(G.ExpectedLuaWarnings, {
                warnText = 'Unknown frame type: ' .. name,
                warnType = 0,
              })
            end
          end
          if not cfg.virtual and name ~= 'TextureCoordTranslation' then -- FIXME
            local factory = factories[name]
              or cfg.frametype and function()
                return assertCreateFrame(name)
              end
            assert(factory, 'missing factory')
            return mkTests(cfg.objtype, factory, function(__index)
              local mtests = {}
              for mname in pairs(cfg.methods) do
                mtests[mname] = function()
                  if not exc or not exc[mname] then
                    return checkCFunc(__index[mname])
                  end
                end
              end
              return mtests
            end)
          end
        end
      end
    end
    return tests
  end

  return {
    apiNamespaces = apiNamespaces,
    build = build,
    cvars = cvars,
    events = events,
    globalApis = globalApis,
    globals = globals,
    product = productTest,
    uiobjects = uiobjects,
  }
end
