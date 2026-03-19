describe('funcheck', function()
  local typecheck = require('wowless.modules.typecheck')(nil, {
    globals = {
      Enum = {},
    },
    uiobjects = {},
  })
  local function log(_, fmt, ...)
    return error(fmt:format(...))
  end
  local funcheck = require('wowless.modules.funcheck')(log, typecheck)
  local function checkret(nexpected, expected, ...)
    assert.same(nexpected, select('#', ...))
    assert.same(expected, { ... })
  end
  local tv = {}
  local uv = newproxy()
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
      ['instride=1, no strides'] = {
        argn = 0,
        args = {},
        spec = {
          inputs = {
            { name = 'i1', type = 'string' },
          },
          instride = 1,
        },
        retn = 0,
        rets = {},
      },
      ['instride=3, multiple strides'] = {
        argn = 7,
        args = { 'cow', tv, uv, 42, tv, uv, 99 },
        spec = {
          inputs = {
            { name = 'o1', type = 'string' },
            { name = 'o2', type = 'table' },
            { name = 'o3', type = 'unknown' },
            { name = 'o4', type = 'number' },
          },
          instride = 3,
        },
        retn = 7,
        rets = { 'cow', tv, uv, 42, tv, uv, 99 },
      },
    }
    for k, v in pairs(tests) do
      it(k, function()
        local check = funcheck.makeCheckInputs('moo', v.spec)
        checkret(v.retn, v.rets, check(unpack(v.args, 1, v.argn)))
      end)
    end
  end)
  describe('warn path', function()
    local warnmsgs
    local function warnlog(_, fmt, ...)
      table.insert(warnmsgs, fmt:format(...))
    end
    local wtc = require('wowless.modules.typecheck')(nil, {
      globals = { Enum = { TestEnum = { Foo = 1 } } },
      uiobjects = {},
    })
    local wfc = require('wowless.modules.funcheck')(warnlog, wtc)
    it('propagates invalid enum value and logs warning', function()
      warnmsgs = {}
      local check = wfc.makeCheckInputs('moo', {
        inputs = { { name = 'e', type = { enum = 'TestEnum' } } },
      })
      checkret(1, { 99 }, check(99))
      assert.same(1, #warnmsgs)
    end)
    it('propagates invalid instride enum value and logs warning', function()
      warnmsgs = {}
      local check = wfc.makeCheckInputs('moo', {
        inputs = {
          { name = 'e1', type = { enum = 'TestEnum' } },
          { name = 'e2', type = { enum = 'TestEnum' } },
        },
        instride = 2,
      })
      checkret(2, { 99, 88 }, check(99, 88))
      assert.same(2, #warnmsgs)
    end)
  end)
  describe('makeCheckOutputs', function()
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
            { name = 'o3', type = 'unknown' },
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
