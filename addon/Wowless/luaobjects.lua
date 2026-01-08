local _, G = ...

local assertEquals = G.assertEquals

local readonlys = {}
for k, v in pairs(_G.WowlessData.LuaObjects) do
  local readonly = {
    __eq = 'nil',
    __index = 'nil',
    __metatable = 'nil',
    __newindex = 'nil',
    __tostring = 'nil',
  }
  for method in pairs(v) do
    readonly[method] = 'function'
  end
  readonlys[k] = readonly
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
    readonly = function()
      local t = {}
      for k, v in pairs(readonlys[ty]) do
        t[k] = function()
          return {
            modify = function()
              local success, msg = pcall(function()
                o[k] = nil
              end)
              assertEquals(false, success, k)
              assertEquals('Attempted to assign to read-only key ' .. k, msg:sub(-37 - k:len()))
            end,
            type = function()
              assertEquals(v, type(o[k]))
            end,
          }
        end
      end
      return t
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
