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
    end)
  end)
end)
