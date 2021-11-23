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
      it('accepts strings', function()
        accept('any', 'foo')
      end)
      it('accepts tables', function()
        accept('any', {})
      end)
    end)
    describe('string', function()
      it('rejects nil', function()
        reject('string', nil)
      end)
      it('rejects numbers', function()
        reject('string', 42)
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
    end)
    describe('oneof', function()
      local ty = {
        oneof = {},
      }
      it('rejects nil', function()
        reject(ty, nil)
      end)
      it('rejects numbers', function()
        reject(ty, 42)
      end)
      it('rejects strings', function()
        reject(ty, 'foo')
      end)
      it('rejects empty tables', function()
        reject(ty, {})
      end)
    end)
  end)
end)
