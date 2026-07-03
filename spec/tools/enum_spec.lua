describe('enum', function()
  local computeMeta = require('tools.enum').computeMeta
  local tests = {
    ['simple'] = {
      name = 'SomeEnum',
      values = { A = 0, B = 2, C = 1 },
      meta = { MaxValue = 2, MinValue = 0, NumValues = 3 },
    },
    ['negative values'] = {
      name = 'SomeEnum',
      values = { A = -1, B = 0, C = 1 },
      meta = { MaxValue = 1, MinValue = -1, NumValues = 3 },
    },
    ['wraps values at or above 2^31'] = {
      name = 'SomeEnum',
      values = { A = 0, B = 2 ^ 31 },
      meta = { MaxValue = -(2 ^ 31), MinValue = 0, NumValues = 2 },
    },
    ['ignores already-negative values for MaxValue'] = {
      name = 'SomeEnum',
      values = { A = -5, B = -1 },
      meta = { MaxValue = nil, MinValue = -5, NumValues = 2 },
    },
    ['AccountStateLoadedFlags uses fixed sentinels'] = {
      name = 'AccountStateLoadedFlags',
      values = { A = '0x0000000000200000', B = '0x0000000000000001' },
      meta = { MaxValue = -2147483648, MinValue = 0, NumValues = 2 },
    },
    ['CreateAllAccountData uses fixed sentinels'] = {
      name = 'CreateAllAccountData',
      values = { A = '0x0000000000200000' },
      meta = { MaxValue = -2147483648, MinValue = 0, NumValues = 1 },
    },
    ['does not wrap values at or above 2^31 when metafix is set'] = {
      name = 'SomeEnum',
      values = { A = 0, B = 2 ^ 31 },
      metafix = true,
      meta = { MaxValue = 2 ^ 31, MinValue = 0, NumValues = 2 },
    },
    ['AccountStateLoadedFlags uses lexicographic values when metafix is set'] = {
      name = 'AccountStateLoadedFlags',
      values = { A = '0x0000000000200000', B = '0x0000000000000001' },
      metafix = true,
      meta = { MaxValue = '0x0000000000200000', MinValue = '0x0000000000000001', NumValues = 2 },
    },
  }
  for k, v in pairs(tests) do
    it(k, function()
      assert.same(v.meta, computeMeta(v.name, v.values, v.metafix))
    end)
  end
end)
