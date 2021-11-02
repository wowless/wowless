describe('core', function()
  local modulefn = loadfile('data/modules/core.lua')
  describe('hooksecurefunc', function()
    it('hooks members', function()
      local log = {}
      local func = function(a, b, c)
        table.insert(log, string.format('func(%d, %d, %d)', a, b, c))
        return a+1, b+1, c+1
      end
      local hook = function(a, b, c)
        table.insert(log, string.format('hook(%d, %d, %d)', a, b, c))
        return a-1, b-1, c-1
      end
      local t = { func = func }
      assert.same({}, {modulefn().api.hooksecurefunc(t, 'func', hook)})
      assert.Not.equals(func, t.func)
      assert.Not.equals(func, t.hook)
      assert.same({13, 35, 57}, {t.func(12, 34, 56)})
      assert.same({'func(12, 34, 56)', 'hook(12, 34, 56)'}, log)
    end)
  end)
end)
