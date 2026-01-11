local _, G = ...

local assertEquals = G.assertEquals

local config = _G.WowlessData.Config.modules and _G.WowlessData.Config.modules.luaobjects or {}

local metamethods = {
  __eq = true,
  __index = true,
  __metatable = true,
  __newindex = true,
  __tostring = config.tostring_metamethod or nil,
}

local function checkReadonly(o, k)
  local success, msg = pcall(function()
    o[k] = nil
  end)
  assertEquals(false, success, k)
  assertEquals('Attempted to assign to read-only key ' .. k, msg:sub(-37 - k:len()))
end

local function checkLuaObject(ty, o)
  return {
    metatable = function()
      local mt = getmetatable(o)
      return {
        type = function()
          assertEquals('boolean', type(mt))
        end,
        value = function()
          assertEquals(false, mt)
        end,
      }
    end,
    metamethods = function()
      local t = {}
      for k in pairs(metamethods) do
        t[k] = function()
          return {
            modify = function()
              return checkReadonly(o, k)
            end,
            type = function()
              assertEquals('nil', type(o[k]))
            end,
          }
        end
      end
      return t
    end,
    methods = function()
      local t = {}
      for k in pairs(_G.WowlessData.LuaObjects[ty]) do
        t[k] = function()
          return {
            modify = function()
              return checkReadonly(o, k)
            end,
            notluafunc = function()
              assertEquals(false, (pcall(coroutine.create, o[k])))
            end,
            type = function()
              assertEquals('function', type(o[k]))
            end,
          }
        end
      end
      return t
    end,
    methodsunique = function()
      local seen = {}
      for k in pairs(_G.WowlessData.LuaObjects[ty]) do
        local fn = o[k]
        assertEquals(nil, seen[fn], k)
        seen[fn] = k
      end
    end,
    selfeq = function()
      assertEquals(o, o)
    end,
    tostring = config.tostring_metamethod and function()
      assert(tostring(o):match('^' .. ty .. ': 0x[0-9a-f]+$'))
    end or nil,
    type = function()
      assertEquals('userdata', type(o))
    end,
  }
end

local function checkLuaObjectFactory(ty, fn)
  return {
    fields = function()
      local o = fn()
      assertEquals(nil, o.WowlessStuff)
      o.WowlessStuff = 'wowless'
      assertEquals('wowless', o.WowlessStuff)
      o.WowlessStuff = nil
      assertEquals(nil, o.WowlessStuff)
    end,
    independentfields = function()
      local o1 = fn()
      local o2 = fn()
      o1.WowlessStuff = 'wowless'
      assertEquals('wowless', o1.WowlessStuff)
      assertEquals(nil, o2.WowlessStuff)
    end,
    instance = function()
      return checkLuaObject(ty, fn())
    end,
    sharedmethods = function()
      local o1 = fn()
      local o2 = fn()
      local t = {}
      for k in pairs(_G.WowlessData.LuaObjects[ty]) do
        t[k] = function()
          assertEquals(o1[k], o2[k])
        end
      end
      return t
    end,
    unique = function()
      assertEquals(false, fn() == fn())
    end,
  }
end

local factories = {
  AbbreviateConfig = function()
    return _G.CreateAbbreviateConfig({})
  end,
  LuaColorCurveObject = function()
    return _G.C_CurveUtil.CreateColorCurve()
  end,
  LuaCurveObject = function()
    return _G.C_CurveUtil.CreateCurve()
  end,
  LuaDurationObject = function()
    return _G.C_DurationUtil.CreateDuration()
  end,
  LuaFunctionContainer = function()
    return _G.C_FunctionContainers.CreateCallback(function() end)
  end,
  UnitHealPredictionCalculator = function()
    return _G.CreateUnitHealPredictionCalculator()
  end,
}

G.testsuite.luaobjects = function()
  local tests = {}
  for k in pairs(_G.WowlessData.LuaObjects) do
    tests[k] = function()
      return checkLuaObjectFactory(k, assert(factories[k], k))
    end
  end
  return tests
end
