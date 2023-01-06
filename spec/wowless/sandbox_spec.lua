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
  describe('register', function()
    it('works', function()
      local sandbox = lib.create()
      sandbox:register('foobar', function(a, b, c)
        return 'foobar ' .. (a + b + c)
      end)
      sandbox:register('bazquux', function()
        return { 42, 99 }, 'moo'
      end)
      assert.same('foobar 6', sandbox:eval('return foobar(1, 2, 3)'))
      assert.same('moo2', sandbox:eval('local t, s = bazquux(); return s .. #t'))
    end)
    it('throws appropriately', function()
      local sandbox = lib.create()
      sandbox:register('foobar', error)
      assert.has_error(function()
        sandbox:eval('foobar("blah")')
      end, 'eval error: blah')
    end)
    it('proxies tables', function()
      local sandbox = lib.create()
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
      sandbox:register('foobar', function(t)
        return { t:get('foo'), t:get(42), t:rawget('foo'), t:rawget(42) }
      end)
      assert.same({ 'bar', 'moo 42', 'bar', nil }, sandbox:eval('return foobar(t)'))
      sandbox:register('foobar', function(t)
        t:set('baz', 52)
      end)
      assert.same(57, sandbox:eval('foobar(t); return t.baz'))
      sandbox:register('foobar', function(t)
        t:rawset('baz', 62)
      end)
      assert.same(62, sandbox:eval('foobar(t); return t.baz'))
      sandbox:register('foobar', function(t)
        t:set('baz', 72)
      end)
      assert.same(72, sandbox:eval('foobar(t); return t.baz'))
      sandbox:register('foobar', function(t)
        t:set('baz', nil)
      end)
      assert.same('moo baz', sandbox:eval('foobar(t); return t.baz'))
    end)
  end)
end)
