describe('funcheck', function()
  local typecheck = require('wowless.typecheck')({
    datalua = {
      globals = {
        Enum = {},
      },
      uiobjects = {},
    },
  })
  local funcheck = require('wowless.funcheck')(typecheck)
  describe('makeCheckOutputs', function()
    it('works with outstride=1', function()
      assert(funcheck.makeCheckOutputs('moo', {
        outputs = {
          { name = 'o1', type = 'string' },
          { name = 'o2', type = 'table' },
        },
        outstride = 1,
      })('cow', {}))
    end)
    it('works with outstride=3', function()
      assert(funcheck.makeCheckOutputs('moo', {
        outputs = {
          { name = 'o1', type = 'string' },
          { name = 'o2', type = 'table' },
          { name = 'o3', type = 'userdata' },
          { name = 'o4', type = 'number' },
        },
        outstride = 3,
      })('cow', {}, newproxy(), 42, {}, newproxy(), 99))
    end)
  end)
end)
