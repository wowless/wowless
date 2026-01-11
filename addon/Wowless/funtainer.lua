local _, G = ...

local assertEquals = G.assertEquals

local config = _G.WowlessData.Config.modules and _G.WowlessData.Config.modules.luaobjects or {}

local readonly = {
  __eq = 'nil',
  __index = 'nil',
  __metatable = 'nil',
  __newindex = 'nil',
  __tostring = config.tostring_metamethod and 'nil' or nil,
  Cancel = 'function',
  Invoke = 'function',
  IsCancelled = 'function',
}

local repft = _G.C_FunctionContainers.CreateCallback(function() end)

G.checkFuntainer = function(ft)
  return {
    metatable = function()
      local mt = getmetatable(ft)
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
      for k, v in pairs(readonly) do
        t[k] = function()
          return {
            modify = function()
              local success, msg = pcall(function()
                ft[k] = nil
              end)
              assertEquals(false, success, k)
              assertEquals('Attempted to assign to read-only key ' .. k, msg:sub(-37 - k:len()))
            end,
            notluafunc = function()
              assertEquals(false, pcall(coroutine.create, ft[k]))
            end,
            type = function()
              assertEquals(v, type(ft[k]))
            end,
          }
        end
      end
      return t
    end,
    repft = function()
      return {
        Cancel = function()
          assertEquals(repft.Cancel, ft.Cancel)
        end,
        Invoke = function()
          assertEquals(repft.Invoke, ft.Invoke)
        end,
        IsCancelled = function()
          assertEquals(repft.IsCancelled, ft.IsCancelled)
        end,
      }
    end,
    selfeq = function()
      assertEquals(ft, ft)
    end,
    tostring = config.tostring_metamethod and function()
      assert(tostring(ft):match('^LuaFunctionContainer: 0x[0-9a-f]+$'))
    end or nil,
    type = function()
      assertEquals('userdata', type(ft))
    end,
  }
end

G.checkFuntainerFactory = function(factory)
  return {
    cancel = function()
      local n = 0
      local ft = factory(function()
        n = n + 1
      end)
      assertEquals(0, n)
      G.check1(false, ft:IsCancelled())
      G.check0(ft:Invoke())
      assertEquals(1, n)
      G.check1(false, ft:IsCancelled())
      G.check0(ft:Invoke())
      assertEquals(2, n)
      G.check1(false, ft:IsCancelled())
      G.check0(ft:Cancel())
      assertEquals(2, n)
      G.check1(true, ft:IsCancelled())
      G.check0(ft:Invoke())
      assertEquals(2, n)
      G.check1(true, ft:IsCancelled())
      G.check0(ft:Cancel())
      assertEquals(2, n)
      G.check1(true, ft:IsCancelled())
    end,
    capture = function()
      local t, n
      local function capture(...)
        n = select('#', ...)
        t = { ... }
        return 99, 'sdfg', 'this is not returned'
      end
      G.check0(factory(capture):Invoke(42, 'asdf'))
      assertEquals(2, n)
      assertEquals(2, #t)
      assertEquals(42, t[1])
      assertEquals('asdf', t[2])
    end,
    fields = function()
      local ft = factory(function() end)
      assertEquals(nil, ft.WowlessStuff)
      ft.WowlessStuff = 'wowless'
      assertEquals('wowless', ft.WowlessStuff)
      ft.WowlessStuff = nil
      assertEquals(nil, ft.WowlessStuff)
    end,
    funtainer = function()
      return G.checkFuntainer(factory(function() end))
    end,
    independentfields = function()
      local ft = factory(function() end)
      local ft2 = factory(function() end)
      ft.WowlessStuff = 'wowless'
      assertEquals('wowless', ft.WowlessStuff)
      assertEquals(nil, ft2.WowlessStuff)
    end,
    luaonly = function()
      assertEquals(false, (pcall(factory, pcall)))
    end,
    unique = function()
      local f = function() end
      assertEquals(false, factory(f) == factory(f))
    end,
  }
end
