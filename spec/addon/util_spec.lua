describe('util', function()
  local env = {}
  loadfile('addon/Wowless/util.lua')('foo', env)

  describe('assertRecursivelyEqual', function()
    local f = assert(env.assertRecursivelyEqual)

    local equalCases = {
      numbers = { value = 3 },
      strings = { value = 'foo' },
      ['true booleans'] = { value = true },
      ['false booleans'] = { value = false },
      nils = { value = nil },
    }
    for name, case in pairs(equalCases) do
      it('returns nil on equal ' .. name, function()
        assert.Nil(f(case.value, case.value))
      end)
    end

    local unequalCases = {
      numbers = { a = 3, b = 4 },
      strings = { a = 'foo', b = 'bar' },
      booleans = { a = true, b = false },
      ['types (number/boolean)'] = { a = 34, b = false },
      ['types (string/nil)'] = { a = 'foo', b = nil },
      ['types (string/table)'] = { a = 'bar', b = {} },
    }
    for name, case in pairs(unequalCases) do
      it('throws on unequal ' .. name, function()
        assert.errors(function()
          f(case.a, case.b)
        end)
      end)
    end

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
