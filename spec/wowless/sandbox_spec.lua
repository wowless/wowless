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
    _G.foobar = function(x, y, ...)
      return x + 1, tostring(y), ...
    end
    local sandbox = lib.create()
    it('works', function()
      assert.same({ 2, '4', 9 }, { sandbox:eval('return apply("foobar", 1, 4, 9)') })
    end)
    it('throws appropriately', function()
      assert.has_error(function()
        sandbox:eval('return apply("nonsense")')
      end, 'eval error: apply error: attempt to call a nil value')
    end)
  end)
  _G.foobar = nil
end)
