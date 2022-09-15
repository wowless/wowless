describe('sandbox', function()
  local lib = require('wowless.sandbox')
  describe('marshalling', function()
    local works = {
      array = '{ 1, "2", 3 }',
      emptytable = '{}',
      multiple = '1, "2", 3',
      nested = '{ {} }',
      nested2 = '{ { x = { y = { z = 42 } } } }',
      ['nil'] = 'nil',
      onenumber = '42',
      record = '{ a = "x", b = 42 }',
      ['true'] = 'true',
    }
    local fails = {
      ['function'] = 'function() end',
      userdata = 'newproxy()',
    }
    local sandbox = lib.create()
    for k, v in pairs(works) do
      it(k .. ' works', function()
        local f = 'return ' .. v
        assert.same({ loadstring(f)() }, { sandbox:eval(f) })
      end)
    end
    for k, v in pairs(fails) do
      it(k .. ' fails', function()
        assert.errors(function()
          sandbox:eval('return ' .. v)
        end)
      end)
    end
  end)
  it('does not support require', function()
    assert.same(true, lib.create():eval('return require == nil'))
  end)
  describe('apply', function()
    local sandbox = lib.create()
    it('works', function()
      _G.foobar = function(x, y, ...)
        return x + 1, tostring(y), ...
      end
      assert.same({ 2, '4', 9 }, { sandbox:eval('return apply("foobar", 1, 4, 9)') })
    end)
    it('throws appropriately', function()
      assert.has_error(function()
        sandbox:eval('return apply("nonsense")')
      end, 'eval error: apply error: attempt to call a nil value')
    end)
    it('proxies tables', function()
      sandbox:eval([[
        t = setmetatable({ foo = "bar" }, {
          __index = function(_, k)
            return 'moo ' .. k
          end,
          __newindex = function(tt, k, v)
            rawset(tt, k, v + 5)
          end,
        })
      ]])
      _G.foobar = function(t)
        return { t:get('foo'), t:get(42), t:rawget('foo'), t:rawget(42) }
      end
      assert.same({ 'bar', 'moo 42', 'bar', nil }, sandbox:eval('return apply("foobar", t)'))
      _G.foobar = function(t)
        t:set('baz', 52)
      end
      assert.same(57, sandbox:eval('apply("foobar", t); return t.baz'))
      _G.foobar = function(t)
        t:rawset('baz', 62)
      end
      assert.same(62, sandbox:eval('apply("foobar", t); return t.baz'))
      _G.foobar = function(t)
        t:set('baz', 72)
      end
      assert.same(72, sandbox:eval('apply("foobar", t); return t.baz'))
      _G.foobar = function(t)
        t:set('baz', nil)
      end
      assert.same('moo baz', sandbox:eval('apply("foobar", t); return t.baz'))
    end)
  end)
end)
