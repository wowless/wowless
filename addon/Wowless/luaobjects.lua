local _, G = ...

local assertEquals = G.assertEquals

local alltypes = _G.WowlessData.LuaObjects.types
local allmethodnames = _G.WowlessData.LuaObjects.allmethodnames

local metamethods = {
  __eq = true,
  __index = true,
  __metatable = true,
  __newindex = true,
  __tostring = true,
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
      for k in pairs(alltypes[ty]) do
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
      for k in pairs(alltypes[ty]) do
        local fn = o[k]
        assertEquals(nil, seen[fn], k)
        seen[fn] = k
      end
    end,
    unknownmethods = function()
      local t = {}
      for k in pairs(allmethodnames) do
        if not alltypes[ty][k] then
          t[k] = function()
            return {
              index = function()
                assertEquals(nil, o[k])
              end,
              newindex = function()
                local v = {}
                local success = pcall(function()
                  o[k] = v
                end)
                assertEquals(true, success, k)
                assertEquals(v, o[k])
                o[k] = nil
              end,
            }
          end
        end
      end
      return t
    end,
    field_type = function()
      assertEquals(nil, o.type)
    end,
    selfeq = function()
      assertEquals(o, o)
    end,
    tostring = function()
      local s = tostring(o)
      assert(s:match('^' .. ty .. ': 0x[0-9a-f]+$'), s)
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
    sharedmethods = function()
      local o1 = fn()
      local o2 = fn()
      local t = {}
      for k in pairs(alltypes[ty]) do
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
  AbbreviatedNumberFormatter = function()
    return _G.C_StringUtil.CreateAbbreviatedNumberFormatter()
  end,
  DurationTextBinding = function()
    return _G.C_DurationUtil.CreateDurationTextBinding()
  end,
  LuaColorCurveObject = function()
    return _G.C_CurveUtil.CreateColorCurve()
  end,
  LuaCurveObject = function()
    return _G.C_CurveUtil.CreateCurve()
  end,
  LuaDurationManualClock = function()
    return _G.C_DurationUtil.CreateManualClock()
  end,
  LuaDurationObject = function()
    return _G.C_DurationUtil.CreateDuration()
  end,
  LuaFunctionContainer = function()
    return _G.C_FunctionContainers.CreateCallback(function() end)
  end,
  NumericRuleFormatter = function()
    return _G.C_StringUtil.CreateNumericRuleFormatter()
  end,
  SecondsFormatter = function()
    return _G.C_StringUtil.CreateSecondsFormatter()
  end,
  UnitHealPredictionCalculator = function()
    return _G.CreateUnitHealPredictionCalculator()
  end,
}

G.checkLuaObject = checkLuaObject

G.testsuite.luaobjects = function()
  return {
    methodpartition = function()
      local methodids = {}
      for k, v in pairs(alltypes) do
        local o = factories[k]()
        for vk in pairs(v) do
          local t = methodids[o[vk]]
          if not t then
            t = {}
            methodids[o[vk]] = t
          end
          table.insert(t, k .. '/' .. vk)
        end
      end
      local actual = {}
      for _, v in pairs(methodids) do
        table.sort(v)
        actual[table.concat(v, ',')] = true
      end
      G.assertEqualSets(_G.WowlessData.LuaObjects.methodpartition, actual)
    end,
    types = function()
      local tests = {}
      for k in pairs(alltypes) do
        tests[k] = function()
          return checkLuaObjectFactory(k, assert(factories[k], k))
        end
      end
      return tests
    end,
  }
end
