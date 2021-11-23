describe('schema', function()
  describe('validate', function()
    local accept, reject = (function()
      local validate = require('wowapi.schema').validate
      return validate, function(schema, value)
        local success, msg = pcall(function() validate(schema, value) end)
        assert.False(success, msg)
      end
    end)()
    describe('any', function()
      it('accepts nil', function()
        accept('any', nil)
      end)
      it('accepts numbers', function()
        accept('any', 42)
      end)
      it('accepts booleans', function()
        accept('any', true)
      end)
      it('accepts strings', function()
        accept('any', 'foo')
      end)
      it('accepts tables', function()
        accept('any', {})
      end)
    end)
    describe('boolean', function()
      it('rejects nil', function()
        reject('boolean', nil)
      end)
      it('rejects numbers', function()
        reject('boolean', 42)
      end)
      it('accepts booleans', function()
        accept('boolean', true)
      end)
      it('rejects strings', function()
        reject('boolean', 'foo')
      end)
      it('rejects tables', function()
        reject('boolean', {})
      end)
    end)
    describe('string', function()
      it('rejects nil', function()
        reject('string', nil)
      end)
      it('rejects numbers', function()
        reject('string', 42)
      end)
      it('rejects booleans', function()
        reject('string', true)
      end)
      it('accepts strings', function()
        accept('string', 'foo')
      end)
      it('rejects tables', function()
        reject('string', {})
      end)
    end)
    describe('record', function()
      local ty = {
        record = {
          foo = 'string',
          bar = 'string',
          baz = {
            record = {
              quux = 'string',
            },
          },
        },
      }
      it('rejects nil', function()
        reject(ty, nil)
      end)
      it('rejects numbers', function()
        reject(ty, 42)
      end)
      it('rejects booleans', function()
        reject(ty, true)
      end)
      it('rejects strings', function()
        reject(ty, 'foo')
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
        })
      end)
      it('rejects extra nested fields', function()
        reject(ty, {
          foo = 'foo',
          bar = 'bar',
          baz = { quux = 'baz.quux', extra = 'bad' },
        })
      end)
    end)
    describe('mapof', function()
      local mstr = { mapof = 'string' }
      local mnest = { mapof = { mapof = 'string' } }
      it('rejects nil', function()
        reject(mstr, nil)
        reject(mnest, nil)
      end)
      it('rejects numbers', function()
        reject(mstr, 42)
        reject(mnest, 42)
      end)
      it('rejects booleans', function()
        reject(mstr, true)
        reject(mnest, true)
      end)
      it('rejects strings', function()
        reject(mstr, 'foo')
        reject(mnest, 'foo')
      end)
      it('accepts empty tables', function()
        accept(mstr, {})
        accept(mnest, {})
      end)
      it('rejects non-string keys', function()
        reject(mstr, { [42] = 'cow' })
        reject(mnest, { moo = { [42] = 'cow' } })
        reject(mnest, { [42] = { moo = 'cow' } })
      end)
      it('rejects wrongly typed values', function()
        reject(mstr, { moo = 42 })
        reject(mnest, { moo = { cow = 42 } })
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
        reject(sstr, nil)
        reject(snest, nil)
      end)
      it('rejects numbers', function()
        reject(sstr, 42)
        reject(snest, 42)
      end)
      it('rejects booleans', function()
        reject(sstr, true)
        reject(snest, true)
      end)
      it('rejects strings', function()
        reject(sstr, 'foo')
        reject(snest, 'foo')
      end)
      it('accepts empty tables', function()
        accept(sstr, {})
        accept(snest, {})
      end)
      it('rejects string keys', function()
        reject(sstr, { moo = 'cow' })
        reject(snest, { { moo = 'cow' } })
      end)
      it('rejects non-arrays', function()
        reject(sstr, { [2] = 'cow' })
        reject(snest, { { [2] = 'cow' } })
      end)
      it('rejects wrongly typed values', function()
        reject(sstr, { 42 })
        reject(snest, { { 42 } })
      end)
      it('accepts valid tables', function()
        accept(sstr, { 'foo', 'bar' })
        accept(snest, { { 'foo', 'bar' }, { 'baz', 'quux' } })
      end)
    end)
    describe('oneof', function()
      it('rejects nil unless any is allowed', function()
        reject({ oneof = {} }, nil)
        reject({ oneof = { 'string' } }, nil)
        accept({ oneof = { 'any' } }, nil)
      end)
      it('rejects numbers unless any is allowed', function()
        reject({ oneof = {} }, 42)
        reject({ oneof = { 'string' } }, 42)
        accept({ oneof = { 'any' } }, 42)
      end)
      it('accepts strings when specified', function()
        reject({ oneof = {} }, 'foo')
        accept({ oneof = { 'string' } }, 'foo')
        accept({ oneof = { 'any' } }, 'foo')
      end)
      it('rejects empty tables unless any is allowed', function()
        reject({ oneof = {} }, {})
        reject({ oneof = { 'string' } }, {})
        accept({ oneof = { 'any' } }, {})
      end)
      it('accepts oneof each', function()
        local ty = {
          oneof = {
            'string',
            'boolean',
            { mapof = 'string' },
            { sequenceof = 'string' },
          },
        }
        accept(ty, 'foo')
        accept(ty, true)
        accept(ty, { foo = 'bar' })
        accept(ty, { 'foo', 'bar' })
      end)
      it('nests', function()
        local ty = {
          oneof = {
            'string',
            {
              oneof = {
                'boolean',
                { mapof = 'string' },
                { sequenceof = 'string' },
              },
            },
          },
        }
        accept(ty, 'foo')
        accept(ty, true)
        accept(ty, { foo = 'bar' })
        accept(ty, { 'foo', 'bar' })
      end)
    end)
  end)
end)
