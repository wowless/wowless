describe('util', function()
  local env = {}
  loadfile('addon/universal/Wowless/util.lua')('foo', env)

  describe('assertRecursivelyEqual', function()
    local f = assert(env.assertRecursivelyEqual)

    it('returns nil on equal numbers', function()
      assert.Nil(f(3, 3))
    end)

    it('returns nil on equal strings', function()
      assert.Nil(f('foo', 'foo'))
    end)

    it('returns nil on equal booleans', function()
      assert.Nil(f(true, true))
      assert.Nil(f(false, false))
    end)

    it('returns nil on nils', function()
      assert.Nil(f(nil, nil))
    end)

    it('throws on unequal numbers', function()
      assert.errors(function()
        f(3, 4)
      end)
    end)

    it('throws on unequal strings', function()
      assert.errors(function()
        f('foo', 'bar')
      end)
    end)

    it('throws on unequal booleans', function()
      assert.errors(function()
        f(true, false)
      end)
    end)

    it('throws on unequal types', function()
      assert.errors(function()
        f(34, false)
      end)
      assert.errors(function()
        f('foo', nil)
      end)
      assert.errors(function()
        f('bar', {})
      end)
    end)

    it('returns empty table on empty tables', function()
      assert.same({}, f({}, {}))
    end)

    local keys = require('pl.tablex').keys

    it('returns test table on nonempty equal tables', function()
      local t = f({ x = 42 }, { x = 42 })
      assert.same({ 'x' }, keys(t))
      assert.same('function', type(t.x))
      assert.Nil(t.x())
    end)

    it('returns test table on nonempty nonequal tables', function()
      local t = f({ x = 42 }, { x = 99 })
      assert.same({ 'x' }, keys(t))
      assert.same('function', type(t.x))
      assert.errors(t.x)
    end)
  end)
end)
