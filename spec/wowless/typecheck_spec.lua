local units = require('wowless.modules.units')()

local tests = {
  ['array of numbers type, string value'] = {
    out = { nil, 'is of type "number array", but "string" was passed' },
    spec = { type = { arrayof = 'number' } },
    value = 'moo',
  },
  ['array of numbers type, table value, empty'] = {
    out = { {} },
    spec = { type = { arrayof = 'number' } },
    value = {},
  },
  ['array of numbers type, table value, non-empty with numbers'] = {
    out = { { 1, 2, 3 } },
    spec = { type = { arrayof = 'number' } },
    value = { 1, 2, 3 },
  },
  ['array of numbers type, table value, non-empty with strings'] = {
    out = { nil, 'element 1 is of type "number", but "string" was passed' },
    spec = { type = { arrayof = 'number' } },
    value = { 'foo', 'bar' },
  },
  ['enum type, number value, membership fails'] = {
    out = { 3, 'is of enum type "Foo", which does not have value 3', true },
    spec = { type = { enum = 'Foo' } },
    value = 3,
  },
  ['enum type, number value, membership succeeds'] = {
    out = { 1 },
    spec = { type = { enum = 'Foo' } },
    value = 1,
  },
  ['enum type, string value, cast succeeds, membership fails'] = {
    out = { 3, 'is of enum type "Foo", which does not have value 3', true },
    spec = { type = { enum = 'Foo' } },
    value = '3',
  },
  ['enum type, string value, cast succeeds, membership succeeds'] = {
    out = { 1 },
    spec = { type = { enum = 'Foo' } },
    value = '1',
  },
  ['enum type, string value, cast fails'] = {
    out = { nil, 'is of type "Foo", but "string" was passed' },
    spec = { type = { enum = 'Foo' } },
    value = 'foo',
  },
  ['framepoint type, invalid value'] = {
    out = { nil, 'is of type "FramePoint", which does not have value "NOTAPOINT"' },
    spec = { type = 'FramePoint' },
    value = 'notapoint',
  },
  ['framepoint type, valid value'] = {
    out = { 'TOPRIGHT' },
    spec = { type = 'FramePoint' },
    value = 'TOPRIGHT',
  },
  ['invalid spec'] = {
    out = { nil, 'invalid spec' },
    spec = { type = 'wat' },
    value = 42,
  },
  ['number type, nil value, default'] = {
    out = { 42 },
    spec = { default = 42, type = 'number' },
  },
  ['number type, number value'] = {
    out = { 42 },
    spec = { type = 'number' },
    value = 42,
  },
  ['number type, string value, cast fails'] = {
    out = { nil, 'is of type "number", but "string" was passed' },
    spec = { type = 'number' },
    value = 'foo',
  },
  ['number type, string value, cast succeeds'] = {
    out = { 42 },
    spec = { type = 'number' },
    value = '42',
  },
  ['number type, table value'] = {
    out = { nil, 'is of type "number", but "table" was passed' },
    spec = { type = 'number' },
    value = {},
  },
  ['string type, number value'] = {
    out = { '42' },
    spec = { type = 'string' },
    value = 42,
  },
  ['string type, string value'] = {
    out = { 'foo' },
    spec = { type = 'string' },
    value = 'foo',
  },
  ['string type, table value'] = {
    out = { nil, 'is of type "string", but "table" was passed' },
    spec = { type = 'string' },
    value = {},
  },
  ['structure type, string value'] = {
    out = { nil, 'is of type "structname", but "string" was passed' },
    spec = { type = { structure = 'structname' } },
    value = 'moo',
  },
  ['structure type, table value'] = {
    out = { { 'moo' } },
    spec = { type = { structure = 'structname' } },
    value = { 'moo' },
  },
  ['structure type, table value, is out'] = {
    isout = true,
    out = { nil, 'has extraneous field 1' },
    spec = { type = { structure = 'structname' } },
    value = { 'moo' },
  },
  ['structure type, table value, is out, has mixin'] = {
    isout = true,
    out = { { a = 42, b = issecure } },
    spec = { type = { structure = 'structwithmixinname' } },
    value = { a = 42, b = issecure },
  },
  ['structure type, table value, is out, has mixin, wrong field'] = {
    isout = true,
    out = { nil, 'has incorrect mixin value b' },
    spec = { type = { structure = 'structwithmixinname' } },
    value = { a = 42, b = 'moo' },
  },
  ['unit type, string value, known unit'] = {
    out = { units.player },
    spec = { type = 'unit' },
    value = 'player',
  },
  ['unit type, string value, unknown unit'] = {
    out = { nil },
    spec = { type = 'unit' },
    value = 'foo',
  },
}

describe('typecheck', function()
  local typecheck = require('wowless.typecheck')({
    datalua = {
      globals = {
        Enum = {
          Foo = {
            FOOKEY1 = 1,
            FOOKEY2 = 2,
          },
        },
      },
      structures = {
        structname = {
          fields = {},
        },
        structwithmixinname = {
          fields = {
            a = {
              type = 'number',
            },
          },
          mixin = 'roflmixin',
        },
      },
      uiobjects = {},
    },
    env = {
      roflmixin = {
        b = issecure,
      },
    },
    modules = {
      units = units,
    },
  })
  for name, test in pairs(tests) do
    it(name, function()
      assert.same(test.out, { typecheck(test.spec, test.value, test.isout) })
    end)
  end
end)
