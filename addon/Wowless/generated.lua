local _, G = ...
local assertEquals = _G.assertEquals
local iswowlesslite = _G.__wowless and _G.__wowless.lite

assert(_G.WowlessData, 'missing WowlessData')

local capsuleconfig = _G.WowlessData.Config.addon.capsule or {}
local capsuleapis = capsuleconfig.globalapis or {}

local function tget(t, s)
  local dot = s:find('%.')
  if dot then
    local p = s:sub(1, dot - 1)
    return t[p] and t[p][s:sub(dot + 1)]
  else
    return t[s]
  end
end

G.testsuite.generated = function()
  local cfuncs = {}

  local function checkFunc(func, isLua)
    assertEquals('function', type(func))
    return {
      getfenv = function()
        assertEquals(_G, getfenv(func))
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

  local function mkftests(cfgs, ename)
    local ret = {}
    local env = ename and _G[ename] or _G
    for name, cfg in pairs(cfgs) do
      cfg = cfg == true and {} or cfg
      ret[name] = function()
        local func = env[name]
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
        elseif cfg.overwritten then
          return checkFunc(func, not iswowlesslite)
        elseif capsuleapis[(ename and ename .. '.' or '') .. name] and not iswowlesslite then
          assertEquals(nil, func)
        else
          return checkCFunc(func)
        end
      end
    end
    return ret
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
    for name, ncfg in pairs(_G.WowlessData.NamespaceApis) do
      tests[name] = function()
        if capsulens[name] and not iswowlesslite then
          assertEquals(nil, _G[name])
        else
          local ns = _G[name]
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          local mtests = mkftests(ncfg, name)
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
      IsDebugBuild = function()
        G.check1(false, _G.IsDebugBuild())
      end,
      IsPublicBuild = function()
        G.check1(true, _G.IsPublicBuild())
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
      local getall = _G.C_Console and _G.C_Console.GetAllCommands or _G.ConsoleGetAllCommands
      local t = {}
      for _, command in ipairs(getall()) do
        local name = command.command
        if name:sub(1, 6) ~= 'CACHE-' then
          assertEquals(nil, t[name])
          t[name] = _G.C_CVar.GetCVarDefault(name)
        end
      end
      return t
    end)())
    local toskipin = _G.WowlessData.Config.addon.ignore_cvar_value or {}
    local tests = {}
    for k, v in pairs(expectedCVars) do
      tests[v.name] = function()
        local actual = actualCVars[k]
        assert(actual, format('extra cvar', k))
        assertEquals(v.name, actual.name, 'cvar name mismatch')
        if not toskipin[actual.name] then
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
    local tests = mkftests(_G.WowlessData.GlobalApis)
    for k in pairs(_G.WowlessData.Config.addon.hooked_globals or {}) do
      assert(not tests[k], k)
      tests[k] = function()
        if iswowlesslite then
          assert(_G[k] == nil)
        else
          return checkCFunc(_G[k])
        end
      end
    end
    for k, v in pairs(_G) do
      if type(v) == 'function' and not tests[k] and not tests['~' .. k] then
        tests['~' .. k] = function()
          return checkNotCFunc(v)
        end
      end
    end
    return tests
  end

  local function globals()
    local data = _G.WowlessData.Globals
    local actualEnum = _G.Enum or {}
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

  local function impltests()
    local tests = {}
    local arg = {
      assertEquals = G.assertEquals,
      assertRecursivelyEqual = G.assertRecursivelyEqual,
      check2 = G.check2,
      check6 = G.check6,
      check7 = G.check7,
      data = {
        build = _G.WowlessData.Build,
      },
      env = _G,
      mixin = G.mixin,
      retn = G.retn,
      wowless = _G.__wowless,
    }
    for k, v in pairs(_G.WowlessData.ImplTests) do
      tests[k] = function()
        local vv = loadstring(v, '@data/test/' .. k .. '.lua')
        return vv(arg)
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
    local warners = _G.WowlessData.Config.runtime.warners
    local function assertCreateFrameFails(ty)
      local success, err = pcall(CreateFrame, ty)
      assert(not success)
      local expectedErr = 'CreateFrame: Unknown frame type \'' .. ty .. '\''
      assertEquals(expectedErr, err:sub(err:len() - expectedErr:len() + 1))
      if warners[ty:lower()] then
        table.insert(G.ExpectedLuaWarnings, {
          warnText = 'Unknown frame type: ' .. ty,
          warnType = 0,
        })
      end
    end
    local indexes = {}
    local function mkTests(objectTypeName, factory, tests)
      local obj, mt
      if objectTypeName == 'Minimap' then
        obj = _G.Minimap or CreateFrame('Minimap')
        mt = getmetatable(obj)
      else
        obj = assert(factory(), 'factory failed')
        local obj2 = assert(factory(), 'factory failed')
        if objectTypeName == 'EditBox' then
          obj:Hide() -- captures input focus otherwise
          obj2:Hide() -- captures input focus otherwise
        end
        assert(obj ~= obj2)
        mt = getmetatable(obj)
        assert(mt == getmetatable(obj2))
      end
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
      local ftests, mtests = tests(__index, obj)
      return {
        contents = function()
          local udk, udv = next(obj)
          assertEquals(udk, 0)
          assertEquals('userdata', type(udv))
          assert(getmetatable(udv) == nil)
          assert(next(obj, udk) == nil or objectTypeName == 'Minimap')
        end,
        fields = function()
          return ftests
        end,
        methods = function()
          for k in pairs(__index) do
            mtests[k] = mtests[k] or function()
              error('missing')
            end
          end
          return mtests
        end,
      }
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
      TextureCoordTranslation = (function()
        local count = 0
        return function()
          count = count + 1
          return _G.WowlessUIObjectTest.AnimationGroup['TextureCoordTranslation' .. count]
        end
      end)(),
      Translation = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Translation')
      end,
      VertexColor = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('VertexColor')
      end,
    }
    local tests = {}
    for name, cfg in pairs(_G.WowlessData.UIObjectApis) do
      tests[name] = function()
        if cfg.unsupported then
          return {
            unsupported = function()
              return {
                createframe = function()
                  assertCreateFrameFails(name)
                end,
                factory = function()
                  local factory = factories[name]
                  if factory then
                    local success, obj = pcall(factory)
                    assert(not success or obj:GetObjectType() ~= name)
                  end
                end,
              }
            end,
          }
        end
        if not cfg.frametype then
          assertCreateFrameFails(name)
        end
        if not cfg.virtual then
          local factory = factories[name]
            or cfg.frametype and function()
              return assertCreateFrame(name)
            end
          assert(factory, 'missing factory')
          return mkTests(cfg.objtype, factory, function(__index, obj)
            local ftests = {}
            for fk, fv in pairs(cfg.fields) do
              ftests[fk] = function()
                local t = {}
                for _, g in ipairs(fv.getters) do
                  t[g.method .. ':' .. g.index] = function()
                    assertEquals(fv.init, (select(g.index, __index[g.method](obj))))
                  end
                end
                return t
              end
            end
            local mtests = {}
            for mname in pairs(cfg.methods) do
              mtests[mname] = function()
                return checkCFunc(__index[mname])
              end
            end
            return ftests, mtests
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
    events = events,
    globalApis = globalApis,
    globals = globals,
    impltests = impltests,
    uiobjects = uiobjects,
  }
end
