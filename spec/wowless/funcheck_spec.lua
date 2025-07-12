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
  local function checkret(nexpected, expected, ...)
    assert.same(nexpected, select('#', ...))
    assert.same(expected, { ... })
  end
  describe('makeCheckInputs', function()
    local tests = {
      ['fills nils'] = {
        argn = 1,
        args = { 'wat' },
        spec = {
          inputs = {
            { name = 'i1', type = 'string' },
            { name = 'i2', nilable = true, type = 'string' },
          },
        },
        retn = 2,
        rets = { 'wat' },
      },
    }
    for k, v in pairs(tests) do
      it(k, function()
        local check = funcheck.makeCheckInputs('moo', v.spec)
        checkret(v.retn, v.rets, check(unpack(v.args, 1, v.argn)))
      end)
    end
  end)
  describe('makeCheckOutputs', function()
    local tv = {}
    local uv = newproxy()
    local tests = {
      ['outstride=1'] = {
        argn = 2,
        args = { 'cow', tv },
        spec = {
          outputs = {
            { name = 'o1', type = 'string' },
            { name = 'o2', type = 'table' },
          },
          outstride = 1,
        },
        retn = 2,
        rets = { 'cow', tv },
      },
      ['outstride=3'] = {
        argn = 7,
        args = { 'cow', tv, uv, 42, tv, uv, 99 },
        spec = {
          outputs = {
            { name = 'o1', type = 'string' },
            { name = 'o2', type = 'table' },
            { name = 'o3', type = 'userdata' },
            { name = 'o4', type = 'number' },
          },
          outstride = 3,
        },
        retn = 7,
        rets = { 'cow', tv, uv, 42, tv, uv, 99 },
      },
    }
    for k, v in pairs(tests) do
      it(k, function()
        local check = funcheck.makeCheckOutputs('moo', v.spec)
        checkret(v.retn, v.rets, check(unpack(v.args, 1, v.argn)))
      end)
    end
  end)
end)
