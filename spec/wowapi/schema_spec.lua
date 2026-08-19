describe('schema', function()
  describe('validate', function()
    local accept, reject = (function()
      local base = require('wowapi.schema').validate
      local function validate(schema, value)
        return base('fake product', schema, value)
      end
      return validate,
        function(schema, value, emsg)
          local success, msg = pcall(validate, schema, value)
          assert.False(success, msg)
          assert.same(emsg, msg)
        end
    end)()
    local function runCase(schema, case)
      if case.error == nil then
        accept(schema, case.value)
      else
        reject(schema, case.value, case.error)
      end
    end
    describe('boolean', function()
      local cases = {
        ['rejects nil'] = { value = nil, error = 'want boolean, got nil' },
        ['rejects numbers'] = { value = 42, error = 'want boolean, got number' },
        ['accepts booleans'] = { value = true },
        ['rejects strings'] = { value = 'foo', error = 'want boolean, got string' },
        ['rejects tables'] = { value = {}, error = 'want boolean, got table' },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase('boolean', case)
        end)
      end
    end)
    describe('number', function()
      local cases = {
        ['rejects nil'] = { value = nil, error = 'want number, got nil' },
        ['accepts numbers'] = { value = 42 },
        ['rejects booleans'] = { value = true, error = 'want number, got boolean' },
        ['rejects strings'] = { value = 'foo', error = 'want number, got string' },
        ['rejects tables'] = { value = {}, error = 'want number, got table' },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase('number', case)
        end)
      end
    end)
    describe('string', function()
      local cases = {
        ['rejects nil'] = { value = nil, error = 'want string, got nil' },
        ['rejects numbers'] = { value = 42, error = 'want string, got number' },
        ['rejects booleans'] = { value = true, error = 'want string, got boolean' },
        ['accepts strings'] = { value = 'foo' },
        ['rejects tables'] = { value = {}, error = 'want string, got table' },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase('string', case)
        end)
      end
    end)
    describe('table', function()
      local cases = {
        ['rejects nil'] = { value = nil, error = 'want table, got nil' },
        ['rejects numbers'] = { value = 42, error = 'want table, got number' },
        ['rejects booleans'] = { value = true, error = 'want table, got boolean' },
        ['rejects strings'] = { value = 'foo', error = 'want table, got string' },
        ['accepts tables'] = { value = {} },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase('table', case)
        end)
      end
    end)
    describe('flag', function()
      local cases = {
        ['accepts true'] = { value = true },
        ['rejects false'] = { value = false, error = 'want flag (boolean true), got boolean (false)' },
        ['rejects nil'] = { value = nil, error = 'want flag (boolean true), got nil' },
        ['rejects numbers'] = { value = 42, error = 'want flag (boolean true), got number' },
        ['rejects strings'] = { value = 'true', error = 'want flag (boolean true), got string' },
        ['rejects tables'] = { value = {}, error = 'want flag (boolean true), got table' },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase('flag', case)
        end)
      end
      describe('in optional record fields', function()
        local ty = {
          record = {
            optionalFlag = { type = 'flag' },
            other = { type = 'string' },
          },
        }
        local recordCases = {
          ['works when omitted'] = { value = { other = 'test' } },
          ['works when true'] = { value = { optionalFlag = true, other = 'test' } },
          ['rejects when false'] = {
            value = { optionalFlag = false, other = 'test' },
            error = { optionalFlag = 'want flag (boolean true), got boolean (false)' },
          },
        }
        for name, case in pairs(recordCases) do
          it(name, function()
            runCase(ty, case)
          end)
        end
      end)
    end)
    describe('record', function()
      local ty = {
        record = {
          foo = { type = 'string' },
          bar = { type = 'string' },
          baz = {
            type = {
              record = {
                quux = { type = 'string' },
              },
            },
          },
        },
      }
      local cases = {
        ['rejects nil'] = { value = nil, error = 'expected table' },
        ['rejects numbers'] = { value = 42, error = 'expected table' },
        ['rejects booleans'] = { value = true, error = 'expected table' },
        ['rejects strings'] = { value = 'foo', error = 'expected table' },
        ['accepts empty tables'] = { value = {} },
        ['accepts all fields'] = {
          value = { foo = 'foo', bar = 'bar', baz = { quux = 'baz.quux' } },
        },
        ['rejects extra fields'] = {
          value = { foo = 'foo', bar = 'bar', baz = { quux = 'baz.quux' }, extra = 'bad' },
          error = { extra = 'unknown field' },
        },
        ['rejects extra nested fields'] = {
          value = { foo = 'foo', bar = 'bar', baz = { quux = 'baz.quux', extra = 'bad' } },
          error = { baz = { extra = 'unknown field' } },
        },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase(ty, case)
        end)
      end
      describe('required fields', function()
        local rty = {
          record = {
            foo = { type = 'string' },
            bar = { required = true, type = 'string' },
          },
        }
        local requiredCases = {
          ['rejects when absent'] = { value = {}, error = { bar = 'missing required field' } },
          ['rejects when other fields present'] = {
            value = { foo = 'foo' },
            error = { bar = 'missing required field' },
          },
          ['accepts when present alone'] = { value = { bar = 'bar' } },
          ['accepts with other fields too'] = { value = { foo = 'foo', bar = 'bar' } },
        }
        for name, case in pairs(requiredCases) do
          it(name, function()
            runCase(rty, case)
          end)
        end
      end)
    end)
    describe('mapof', function()
      local mstr = {
        mapof = {
          key = 'string',
          value = 'string',
        },
      }
      local mnest = {
        mapof = {
          key = 'string',
          value = {
            mapof = {
              key = 'string',
              value = 'string',
            },
          },
        },
      }
      local cases = {
        ['rejects nil'] = { value = nil, error = 'expected table' },
        ['rejects numbers'] = { value = 42, error = 'expected table' },
        ['rejects booleans'] = { value = true, error = 'expected table' },
        ['rejects strings'] = { value = 'foo', error = 'expected table' },
        ['accepts empty tables'] = { value = {} },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase(mstr, case)
          runCase(mnest, case)
        end)
      end
      it('rejects non-string keys', function()
        reject(mstr, { [42] = 'cow' }, { [42] = { key = 'want string, got number' } })
        reject(mnest, { moo = { [42] = 'cow' } }, { moo = { value = { [42] = { key = 'want string, got number' } } } })
        reject(mnest, { [42] = { moo = 'cow' } }, { [42] = { key = 'want string, got number' } })
      end)
      it('rejects wrongly typed values', function()
        reject(mstr, { moo = 42 }, { moo = { value = 'want string, got number' } })
        reject(mnest, { moo = { cow = 42 } }, { moo = { value = { cow = { value = 'want string, got number' } } } })
      end)
      it('accepts valid tables', function()
        accept(mstr, { foo = 'bar', baz = 'quux' })
        accept(mnest, { k1 = { k11 = 'v11', k12 = 'v12' }, k2 = { k21 = 'v21' } })
      end)
    end)
    describe('sequenceof', function()
      local sstr = { sequenceof = 'string' }
      local snest = { sequenceof = { sequenceof = 'string' } }
      local cases = {
        ['rejects nil'] = { value = nil, error = 'expected table' },
        ['rejects numbers'] = { value = 42, error = 'expected table' },
        ['rejects booleans'] = { value = true, error = 'expected table' },
        ['rejects strings'] = { value = 'foo', error = 'expected table' },
        ['accepts empty tables'] = { value = {} },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase(sstr, case)
          runCase(snest, case)
        end)
      end
      it('rejects string keys', function()
        reject(sstr, { moo = 'cow' }, { moo = 'expected number' })
        reject(snest, { { moo = 'cow' } }, { { moo = 'expected number' } })
      end)
      it('rejects non-arrays', function()
        reject(sstr, { [2] = 'cow' }, 'expected array')
        reject(snest, { { [2] = 'cow' } }, { 'expected array' })
      end)
      it('rejects wrongly typed values', function()
        reject(sstr, { 42 }, { 'want string, got number' })
        reject(snest, { { 42 } }, { { 'want string, got number' } })
      end)
      it('accepts valid tables', function()
        accept(sstr, { 'foo', 'bar' })
        accept(snest, { { 'foo', 'bar' }, { 'baz', 'quux' } })
      end)
    end)
    describe('literal', function()
      local ty = { literal = 'foo' }
      local cases = {
        ['rejects nil'] = { value = nil, error = 'string literal mismatch' },
        ['rejects numbers'] = { value = 42, error = 'string literal mismatch' },
        ['rejects booleans'] = { value = true, error = 'string literal mismatch' },
        ['accepts matched string'] = { value = 'foo' },
        ['rejects mismatched string'] = { value = 'bar', error = 'string literal mismatch' },
        ['rejects tables'] = { value = {}, error = 'string literal mismatch' },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase(ty, case)
        end)
      end
    end)
    describe('setof', function()
      local ty = { setof = 'string' }
      local cases = {
        ['accepts empty set'] = { value = {} },
        ['accepts non empty set'] = { value = { a = {}, b = {} } },
        ['rejects wrong keys'] = {
          value = { [42] = {} },
          error = { [42] = { key = 'want string, got number' } },
        },
        ['rejects wrong values'] = {
          value = { a = 42, b = { 99 } },
          error = { a = { value = 'bad value' }, b = { value = 'bad value' } },
        },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase(ty, case)
        end)
      end
    end)
    describe('taggedunion', function()
      local ty = {
        taggedunion = {
          bar = 'number',
          foo = {
            sequenceof = 'string',
          },
        },
      }
      local err = 'expected one of {bar, foo}'
      local cases = {
        ['accepts one'] = { value = { bar = 42 } },
        ['accepts the other'] = { value = { foo = { 'baz', 'quux' } } },
        ['rejects non-table'] = { value = 42, error = err },
        ['rejects empty'] = { value = {}, error = 'missing element, ' .. err },
        ['rejects multiple'] = {
          value = { bar = 42, foo = { 'baz', 'quux' } },
          error = 'multiple elements, ' .. err,
        },
        ['rejects bad keys'] = { value = { baz = 99 }, error = 'bad key, ' .. err },
      }
      for name, case in pairs(cases) do
        it(name, function()
          runCase(ty, case)
        end)
      end
    end)
  end)
end)
