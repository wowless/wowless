local _, G = ...

local assertEquals = G.assertEquals
local cfg = _G.WowlessData.Config.modules and _G.WowlessData.Config.modules.funtainer or {}

local readonly = {
  __eq = 'nil',
  __index = 'nil',
  __metatable = 'nil',
  __newindex = 'nil',
  __tostring = cfg.tostring_metamethod and 'nil',
  Cancel = 'function',
  Invoke = 'function',
  IsCancelled = 'function',
}

local function factory(f)
  return _G.C_Timer.NewTimer((2 ^ 32 - 1) / 1000, f)
end

local repft = factory(function() end)

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
    tostring = function()
      if cfg.tostring_metamethod then
        assert(tostring(ft):match('^LuaFunctionContainer: 0x[0-9a-f]+$'))
      else
        assert(tostring(ft):match('^userdata: 0x[0-9a-f]+$'))
      end
    end,
    type = function()
      assertEquals('userdata', type(ft))
    end,
  }
end

G.testsuite.funtainer = function()
  return {
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
    repft = function()
      return G.checkFuntainer(repft)
    end,
  }
end
