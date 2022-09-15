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
  it('supports apply', function()
    local sandbox = lib.create()
    assert.same({ 1, '2', 3 }, { sandbox:eval('return apply("unpack", { 1, "2", 3 })') })
  end)
end)
