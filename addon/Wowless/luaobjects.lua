local _, G = ...

local assertEquals = G.assertEquals

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
    selfeq = function()
      assertEquals(o, o)
    end,
    tostring = function()
      assert(tostring(o):match('^' .. ty .. ': 0x[0-9a-f]+$'))
    end,
    type = function()
      assertEquals('userdata', type(o))
    end,
  }
end

local function checkLuaObjectFactory(ty, fn)
  return {
    instance = function()
      return checkLuaObject(ty, fn())
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
