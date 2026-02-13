local addonName, G = ...
local assertEquals = _G.assertEquals
local iswowlesslite = _G.__wowless and _G.__wowless.lite

assert(_G.WowlessData, 'missing WowlessData')

local capsuleconfig = _G.WowlessData.Config.addon.capsule or {}
local capsuleapis = capsuleconfig.globalapis or {}

local function newUniqueChecker()
  local t = {}
  local names = {}
  local open = true
  local function addEntry(n, v, b)
    assert(open, n)
    assert(names[n] == nil, n)
    local tt = t[v]
    if not tt then
      tt = {}
      t[v] = tt
    end
    assert(tt[n] == nil, n)
    tt[n] = b
    names[n] = tt
  end
  local function add(n, v)
    return addEntry(n, v, true)
  end
  local function addAlias(n, v)
    return addEntry(n, v, false)
  end
  local function test()
    assert(open)
    open = false
    local tests = {}
    for _, v in pairs(t) do
      local ks = {}
      for vk in pairs(v) do
        table.insert(ks, ('%q'):format(vk))
      end
      table.sort(ks)
      tests[table.concat(ks, ',')] = function()
        local nt = 0
        for _, vv in pairs(v) do
          nt = nt + (vv and 1 or 0)
        end
        if nt == 0 then
          error('no true name')
        elseif nt > 1 then
          error('multiple true names')
        end
      end
    end
    return tests
  end
  return {
    add = add,
    addAlias = addAlias,
    test = test,
  }
end

G.testsuite.generated = function()
  local cfuncs = newUniqueChecker()

  local function isLuaFunc(func)
    return (pcall(coroutine.create, func))
  end

  local function checkCFunc(name, func)
    assertEquals('function', type(func))
    return {
      getfenv = function()
        assertEquals(_G, getfenv(func))
      end,
      impltype = function()
        assertEquals(false, isLuaFunc(func))
        cfuncs.add(name, func)
      end,
    }
  end

  local function checkLuaFunc(func)
    assertEquals('function', type(func))
    return {
      getfenv = function()
        assertEquals(_G, getfenv(func))
      end,
      impltype = function()
        assertEquals(true, isLuaFunc(func))
      end,
    }
  end

  local function checkAliasOrLuaFunc(name, func)
    if not isLuaFunc(func) then
      cfuncs.addAlias(name, func)
    end
  end

  local function mkftests(cfgs, ename)
    local ret = {}
    local env = ename and _G[ename] or _G
    for name, cfg in pairs(cfgs) do
      cfg = cfg == true and {} or cfg
      ret[name] = function()
        local fullname = (ename and ename .. '.' or '') .. name
        local func = env[name]
        if iswowlesslite then
          return checkCFunc(fullname, func)
        elseif cfg.overwritten then
          return checkLuaFunc(func)
        elseif capsuleapis[fullname] then
          assertEquals(nil, func)
        else
          return checkCFunc(fullname, func)
        end
      end
    end
    return ret
  end

  local function apiNamespaces()
    local capsulens = capsuleconfig.apinamespaces or {}
    local tests = {}
    for name, ncfg in pairs(_G.WowlessData.NamespaceApis) do
      tests[name] = function()
        if capsulens[name] and not iswowlesslite then
          assertEquals(nil, _G[name])
        else
          local ns = _G[name]
          assertEquals('table', type(ns))
          assert(getmetatable(ns) == nil)
          local nstests = mkftests(ncfg, name)
          for k, v in pairs(ns) do
            if not nstests[k] then
              nstests[k] = function()
                if name == 'math' and (k == 'huge' or k == 'pi') then
                  assertEquals('number', type(v))
                else
                  return checkAliasOrLuaFunc(name .. '.' .. k, v)
                end
              end
            end
          end
          return nstests
        end
      end
    end
    return tests
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
      for _, command in ipairs(_G.ConsoleGetAllCommands()) do
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
        assert(actual, ('extra cvar %q'):format(k))
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
          error(('missing cvar with default %q'):format(v.value))
        end
      end
    end
    return tests
  end

  local function events()
    local tests = {}
    local frame = CreateFrame('Frame')
    local nop = function() end
    for k, v in pairs(_G.WowlessData.Events) do
      tests[k] = function()
        return {
          RegisterEvent = function()
            if v.registerable then
              return G.match(2, true, not v.restricted, pcall(frame.RegisterEvent, frame, k))
            else
              local err = table.concat({
                'Frame:RegisterEvent(): ',
                'Frame:RegisterEvent(): ',
                'Attempt to register unknown event ',
                '"' .. k .. '"',
              })
              return G.match(2, false, err, pcall(frame.RegisterEvent, frame, k))
            end
          end,
          RegisterEventCallback = frame.RegisterEventCallback and function()
            if v.callback then
              return G.match(2, true, not v.restricted, pcall(frame.RegisterEventCallback, frame, k, nop))
            else
              local err = table.concat({
                'Frame:RegisterEventCallback(): ',
                'Attempt to register unknown event ',
                '"' .. k .. '"',
              })
              return G.match(2, false, err, pcall(frame.RegisterEventCallback, frame, k, nop))
            end
          end,
          RegisterEventCallbackGlobal = _G.RegisterEventCallback and function()
            if v.callback then
              return G.match(2, true, not v.restricted, pcall(_G.RegisterEventCallback, k, nop))
            else
              local err = table.concat({
                'RegisterEventCallback ',
                'Attempt to register unknown event ',
                '"' .. k .. '"',
                '\nLua Taint: ' .. addonName,
              })
              return G.match(2, false, err, pcall(_G.RegisterEventCallback, k, nop))
            end
          end,
        }
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
          return checkCFunc(k, _G[k])
        end
      end
    end
    for k, v in pairs(_G) do
      if type(v) == 'function' and not tests[k] then
        tests[k] = function()
          return checkAliasOrLuaFunc(k, v)
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
    if not iswowlesslite then
      for k in pairs(_G.WowlessData.Config.addon.enums_set_in_framexml or {}) do
        local v = actualEnum[k]
        if v == nil then
          error(('enums_set_in_framexml %s was not set'):format(k), 0)
        end
        expectedEnum[k] = v
      end
      for k, v in pairs(_G.WowlessData.Config.addon.enum_values_set_in_framexml or {}) do
        for vk in pairs(v) do
          local vv = actualEnum[k][vk]
          if vv == nil then
            error(('enum_values_set_in_framexml %s.%s was not set'):format(k, vk), 0)
          end
          expectedEnum[k][vk] = vv
        end
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
      addonName = addonName,
      assertEquals = G.assertEquals,
      assertRecursivelyEqual = G.assertRecursivelyEqual,
      check0 = G.check0,
      check1 = G.check1,
      check2 = G.check2,
      check3 = G.check3,
      check4 = G.check4,
      check5 = G.check5,
      check6 = G.check6,
      check7 = G.check7,
      checkFuntainerFactory = G.checkFuntainerFactory,
      checkLuaObject = G.checkLuaObject,
      data = {
        build = _G.WowlessData.Build,
        config = _G.WowlessData.Config,
        events = _G.WowlessData.Events,
      },
      env = _G,
      match = G.match,
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
    local warners = _G.WowlessData.Config.runtime.warners
    local function assertCreateFrameFails(ty)
      G.check2(false, 'CreateFrame: Unknown frame type \'' .. ty .. '\'', pcall(CreateFrame, ty))
      if warners[ty:lower()] then
        table.insert(G.ExpectedLuaWarnings, 'Unknown frame type: ' .. ty)
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
      EditBox = function()
        -- Hide to avoid focus issues. Using a hidden parent instead breaks the default frame level test.
        local frame = CreateFrame('EditBox')
        frame:Hide()
        return frame
      end,
      FlipBook = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('FlipBook')
      end,
      Font = function()
        return CreateFrame('MessageFrame'):GetFontObject()
      end,
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
      TextureCoordTranslation = function()
        local frame = CreateFrame('Frame', nil, nil, 'WowlessTextureCoordTranslationFactory')
        return frame.AnimationGroup.TextureCoordTranslation
      end,
      Translation = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Translation')
      end,
      VertexColor = function()
        return CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('VertexColor')
      end,
    }
    local indexes = {}
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
        if not cfg.isa.Frame then
          assertCreateFrameFails(name)
        end
        if cfg.virtual then
          return
        end
        local factory = factories[name]
          or cfg.isa.Frame
            and function()
              local frame = G.retn(1, CreateFrame(name))
              assert(type(frame) == 'table')
              return frame
            end
        assert(factory, name)
        local obj, mt
        if cfg.singleton then
          obj = _G[name] or CreateFrame(name)
          mt = getmetatable(obj)
        else
          obj = assert(factory(), 'factory failed')
          local obj2 = assert(factory(), 'factory failed')
          assert(obj ~= obj2)
          mt = getmetatable(obj)
          assert(mt == getmetatable(obj2))
        end
        assert(mt ~= nil)
        assertEquals(cfg.objtype, obj:GetObjectType())
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
            assert(next(obj, udk) == nil or cfg.singleton)
          end,
          fields = function()
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
            return ftests
          end,
          isa = (not _G.__wowless or nil) and function()
            local t = {}
            for k, v in pairs(cfg.isa) do
              t[k] = function()
                return {
                  lowercase = function()
                    return G.match(1, v, obj:IsObjectType(k:lower()))
                  end,
                  mixedcase = function()
                    return G.match(1, v, obj:IsObjectType(k))
                  end,
                }
              end
            end
            return t
          end,
          methods = function()
            local mtests = {}
            for mname in pairs(cfg.methods) do
              mtests[mname] = function()
                return checkCFunc(name .. ':' .. mname, __index[mname])
              end
            end
            for k in pairs(__index) do
              mtests[k] = mtests[k] or function()
                error('missing')
              end
            end
            return mtests
          end,
          scripts = obj.HasScript and function()
            local stests = {}
            for k, v in pairs(cfg.scripts) do
              stests[k] = function()
                return G.match(1, v, obj:HasScript(k))
              end
            end
            return stests
          end,
        }
      end
    end
    return tests
  end

  return {
    apiNamespaces = apiNamespaces,
    cvars = cvars,
    events = events,
    globalApis = globalApis,
    globals = globals,
    impltests = impltests,
    uiobjects = uiobjects,
    ['~cfuncs'] = cfuncs.test,
  }
end
