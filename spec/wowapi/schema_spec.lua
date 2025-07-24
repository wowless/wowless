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
    describe('boolean', function()
      it('rejects nil', function()
        reject('boolean', nil, 'want boolean, got nil')
      end)
      it('rejects numbers', function()
        reject('boolean', 42, 'want boolean, got number')
      end)
      it('accepts booleans', function()
        accept('boolean', true)
      end)
      it('rejects strings', function()
        reject('boolean', 'foo', 'want boolean, got string')
      end)
      it('rejects tables', function()
        reject('boolean', {}, 'want boolean, got table')
      end)
    end)
    describe('number', function()
      it('rejects nil', function()
        reject('number', nil, 'want number, got nil')
      end)
      it('accepts numbers', function()
        accept('number', 42)
      end)
      it('rejects booleans', function()
        reject('number', true, 'want number, got boolean')
      end)
      it('rejects strings', function()
        reject('number', 'foo', 'want number, got string')
      end)
      it('rejects tables', function()
        reject('number', {}, 'want number, got table')
      end)
    end)
    describe('string', function()
      it('rejects nil', function()
        reject('string', nil, 'want string, got nil')
      end)
      it('rejects numbers', function()
        reject('string', 42, 'want string, got number')
      end)
      it('rejects booleans', function()
        reject('string', true, 'want string, got boolean')
      end)
      it('accepts strings', function()
        accept('string', 'foo')
      end)
      it('rejects tables', function()
        reject('string', {}, 'want string, got table')
      end)
    end)
    describe('table', function()
      it('rejects nil', function()
        reject('table', nil, 'want table, got nil')
      end)
      it('rejects numbers', function()
        reject('table', 42, 'want table, got number')
      end)
      it('rejects booleans', function()
        reject('table', true, 'want table, got boolean')
      end)
      it('rejects strings', function()
        reject('table', 'foo', 'want table, got string')
      end)
      it('accepts tables', function()
        accept('table', {})
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
      it('rejects nil', function()
        reject(ty, nil, 'expected table')
      end)
      it('rejects numbers', function()
        reject(ty, 42, 'expected table')
      end)
      it('rejects booleans', function()
        reject(ty, true, 'expected table')
      end)
      it('rejects strings', function()
        reject(ty, 'foo', 'expected table')
      end)
      it('accepts empty tables', function()
        accept(ty, {})
      end)
      it('accepts all fields', function()
        accept(ty, {
          foo = 'foo',
          bar = 'bar',
          baz = { quux = 'baz.quux' },
        })
      end)
      it('rejects extra fields', function()
        reject(ty, {
          foo = 'foo',
          bar = 'bar',
          baz = { quux = 'baz.quux' },
          extra = 'bad',
        }, { extra = 'unknown field' })
      end)
      it('rejects extra nested fields', function()
        reject(ty, {
          foo = 'foo',
          bar = 'bar',
          baz = { quux = 'baz.quux', extra = 'bad' },
        }, { baz = { extra = 'unknown field' } })
      end)
      it('handles required fields', function()
        local rty = {
          record = {
            foo = { type = 'string' },
            bar = { required = true, type = 'string' },
          },
        }
        reject(rty, {}, { bar = 'missing required field' })
        reject(rty, { foo = 'foo' }, { bar = 'missing required field' })
        accept(rty, { bar = 'bar' })
        accept(rty, { foo = 'foo', bar = 'bar' })
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
      it('rejects nil', function()
        reject(mstr, nil, 'expected table')
        reject(mnest, nil, 'expected table')
      end)
      it('rejects numbers', function()
        reject(mstr, 42, 'expected table')
        reject(mnest, 42, 'expected table')
      end)
      it('rejects booleans', function()
        reject(mstr, true, 'expected table')
        reject(mnest, true, 'expected table')
      end)
      it('rejects strings', function()
        reject(mstr, 'foo', 'expected table')
        reject(mnest, 'foo', 'expected table')
      end)
      it('accepts empty tables', function()
        accept(mstr, {})
        accept(mnest, {})
      end)
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
      it('rejects nil', function()
        reject(sstr, nil, 'expected table')
        reject(snest, nil, 'expected table')
      end)
      it('rejects numbers', function()
        reject(sstr, 42, 'expected table')
        reject(snest, 42, 'expected table')
      end)
      it('rejects booleans', function()
        reject(sstr, true, 'expected table')
        reject(snest, true, 'expected table')
      end)
      it('rejects strings', function()
        reject(sstr, 'foo', 'expected table')
        reject(snest, 'foo', 'expected table')
      end)
      it('accepts empty tables', function()
        accept(sstr, {})
        accept(snest, {})
      end)
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
      it('rejects nil', function()
        reject(ty, nil, 'string literal mismatch')
      end)
      it('rejects numbers', function()
        reject(ty, 42, 'string literal mismatch')
      end)
      it('rejects booleans', function()
        reject(ty, true, 'string literal mismatch')
      end)
      it('accepts matched string', function()
        accept(ty, 'foo')
        reject(ty, 'bar', 'string literal mismatch')
      end)
      it('rejects tables', function()
        reject(ty, {}, 'string literal mismatch')
      end)
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
      it('accepts one', function()
        accept(ty, { bar = 42 })
      end)
      it('accepts the other', function()
        accept(ty, { foo = { 'baz', 'quux' } })
      end)
      it('rejects non-table', function()
        reject(ty, 42, 'expected table')
      end)
      it('rejects empty', function()
        reject(ty, {}, 'missing element')
      end)
      it('rejects multiple', function()
        reject(ty, { bar = 42, foo = { 'baz', 'quux' } }, 'multiple elements')
      end)
      it('rejects bad keys', function()
        reject(ty, { baz = 99 }, 'bad key')
      end)
    end)
  end)
end)
