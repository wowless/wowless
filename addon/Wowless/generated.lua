local _, G = ...
local assertEquals = _G.assertEquals
local iswowlesslite = _G.__wowless and _G.__wowless.lite

local capsuleEnv = _G.SimpleCheckout and getfenv(_G.SimpleCheckout.OnLoad) or {}

assert(_G.WowlessData, 'missing WowlessData')

local capsuleconfig = _G.WowlessData.Config.capsule or {}

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
        assertEquals(isLua, (pcall(coroutine.create, func)))
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
    local capsulens = capsuleconfig.apinamespaces or {}
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
      if not capsulens[name] then
        tests[name] = function()
          local ns = _G[name] or capsuleEnv[name]
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          local mtests = {}
          for mname, mcfg in pairs(ncfg) do
            mcfg = mcfg == true and empty or mcfg
            mtests[mname] = function()
              local func = ns[mname]
              if mcfg.alias then
                assertEquals(func, assert(tget(_G, mcfg.alias)))
              elseif mcfg.stdlib then
                local ty = type(tget(_G, mcfg.stdlib))
                if ty == 'function' then
                  return checkCFunc(func)
                else
                  assertEquals(ty, type(func))
                end
              elseif not mcfg.overwritten then
                return checkCFunc(func)
              end
              -- Do nothing on overwritten APIs. They're Lua when processing
              -- FrameXML, and C when running bare.
            end
          end
          return mkTests(ns, mtests)
        end
      end
    end
    return tests
  end

  local function build()
    local b = _G.WowlessData.Build
    assert(b, 'no build')
    return {
      GetBuildInfo = function()
        if b.tocversion == 30402 or b.tocversion == 11404 then
          G.check7(b.version, b.build, b.date, b.tocversion, '', ' ', b.tocversion, GetBuildInfo())
        elseif b.tocversion >= 100100 then
          G.check6(b.version, b.build, b.date, b.tocversion, '', ' ', GetBuildInfo())
        else
          G.check4(b.version, b.build, b.date, b.tocversion, GetBuildInfo())
        end
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
    local function lowify(t)
      local tt = {}
      for k, v in pairs(t) do
        local lk = k:lower()
        assertEquals(nil, tt[lk])
        tt[lk] = {
          name = k,
          value = v,
        }
      end
      return tt
    end
    local expectedCVars = lowify(_G.WowlessData.CVars)
    local actualCVars = lowify((function()
      -- Do this early to avoid issues with deferred cvar creation.
      local t = {}
      for _, command in ipairs(_G.C_Console.GetAllCommands()) do
        local name = command.command
        if name:sub(1, 6) ~= 'CACHE-' then
          assertEquals(nil, t[name])
          t[name] = _G.C_CVar.GetCVarDefault(name)
        end
      end
      return t
    end)())
    local toskipin = _G.WowlessData.Config.ignore_cvar_value or {}
    local tests = {}
    for k, v in pairs(expectedCVars) do
      tests[v.name] = function()
        local actual = actualCVars[k]
        assert(actual, format('extra cvar', k))
        assertEquals(v.name, actual.name, 'cvar name mismatch')
        if not toskipin[k] then
          assertEquals(v.value, actual.value, 'cvar value mismatch')
        end
      end
    end
    local toskipout = {
      praisethesun = true, -- set in FrameXML
      ttsusecharactersettings = true,
    }
    for k, v in pairs(actualCVars) do
      if not tests[v.name] and not toskipout[k] then
        tests[v.name] = function()
          error(format('missing cvar with default %q', v.value))
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
        assertEquals(v.registerable, (pcall(frame.RegisterEvent, frame, k)))
      end
    end
    return tests
  end

  local function globalApis()
    local capsuleapis = capsuleconfig.globalapis or {}
    local tests = {}
    local empty = {}
    for name, cfg in pairs(_G.WowlessData.GlobalApis) do
      cfg = cfg == true and empty or cfg
      tests[name] = function()
        local func = _G[name] or capsuleEnv[name]
        if cfg.alias then
          assertEquals(func, assert(tget(_G, cfg.alias)))
        elseif cfg.nowrap then
          return checkLuaFunc(func)
        elseif cfg.stdlib then
          local ty = type(tget(_G, cfg.stdlib))
          if ty == 'function' then
            return checkCFunc(func)
          else
            assertEquals(ty, type(func))
          end
        elseif not capsuleapis[name] then
          return checkCFunc(func)
        end
      end
    end
    for k in pairs(_G.WowlessData.Config.hooked_globals or {}) do
      assert(not tests[k], k)
      tests[k] = function()
        if iswowlesslite then
          assert(_G[k] == nil)
        else
          return checkCFunc(_G[k])
        end
      end
    end
    for k in pairs(_G.WowlessData.Config.globalenv_in_capsule or {}) do
      assert(not tests[k], k)
      tests[k] = function()
        local v = capsuleEnv[k]
        if iswowlesslite then
          assert(v == nil)
        else
          return checkLuaFunc(v, _G)
        end
      end
    end
    local function checkEnv(env)
      for k, v in pairs(env) do
        if type(v) == 'function' and not tests[k] and not tests['~' .. k] then
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
    local actualEnum = G.mixin({}, _G.Enum, capsuleEnv.Enum or {})
    local capsuleenums = capsuleconfig.enums or {}
    local expectedEnum = {}
    for k, v in pairs(data.Enum) do
      if not capsuleenums[k] or actualEnum[k] then
        expectedEnum[k] = v
      end
    end
    local tests = {
      Enum = function()
        return G.assertRecursivelyEqual(expectedEnum, actualEnum)
      end,
    }
    for k, v in pairs(data) do
      if k ~= 'Enum' then
        tests[k] = function()
          return G.assertRecursivelyEqual(v, _G[k])
        end
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
    -- Some work differently for some reason.
    local exceptions = {
      LE_EXPANSION = true,
      LE_GAME_ERR = true,
    }
    for k in pairs(exceptions) do
      assert(genums[k] == nil)
      genums[k] = true
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
      local success, err = pcall(CreateFrame, ty)
      assert(not success)
      local expectedErr = 'CreateFrame: Unknown frame type \'' .. ty .. '\''
      assertEquals(expectedErr, err:sub(err:len() - expectedErr:len() + 1))
    end
    local indexes = {}
    local function mkTests(objectTypeName, zombie, factory, tests)
      local obj = assert(factory(), 'factory failed')
      local obj2 = assert(factory(), 'factory failed')
      if objectTypeName == 'EditBox' then
        obj:Hide() -- captures input focus otherwise
        obj2:Hide() -- captures input focus otherwise
      end
      assert(obj ~= obj2)
      local mt = getmetatable(obj)
      assert(mt == getmetatable(obj2))
      if zombie then
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
      FlipBook = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('FlipBook')
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
      Line = {
        AdjustPointsOffset = true,
        ClearPointByName = true,
        ClearPointsOffset = true,
        GetNumPoints = true,
        GetPoint = true,
        GetPointByName = true,
        SetAllPoints = true,
        SetHeight = true,
        SetPoint = true,
        SetSize = true,
        SetWidth = true,
      },
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
            if cfg.warner then
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
            return mkTests(cfg.objtype, cfg.zombie, factory, function(__index)
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
    uiobjects = uiobjects,
  }
end
