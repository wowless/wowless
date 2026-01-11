local _, G = ...

local assertEquals = G.assertEquals

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
    luaonly = function()
      assertEquals(false, (pcall(factory, pcall)))
    end,
  }
end
