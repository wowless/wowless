describe('uiobjects', function()
  for filename in require('lfs').dir('data/uiobjects') do
    if filename ~= '.' and filename ~= '..' then
      assert(filename:sub(-4) == '.lua', 'invalid file ' .. filename)
      local fn = assert(loadfile('data/uiobjects/' .. filename))
      describe(filename, function()
        local t = setfenv(fn, {
          api = { frames = {} },
          loader = { version = 'moo' },
          table = { insert = table.insert },
          u = function() return {} end,
        })()
        assert.same('table', type(t))
        it('has only valid fields', function()
          local fields = {
            constructor = true,
            inherits = true,
            mixin = true,
          }
          for k in pairs(t) do
            assert(fields[k], ('invalid field %q'):format(k))
          end
        end)
        it('has a valid inherits table', function()
          assert.same('table', type(t.inherits))
          for _, v in ipairs(t.inherits) do
            assert.same('string', type(v))
          end
        end)
        if t.constructor then
          it('has a valid constructor', function()
            assert.same('function', type(t.constructor))
            t.constructor({})
          end)
        end
        if t.mixin then
          it('has a valid mixin', function()
            assert.same('table', type(t.mixin))
            for k, v in pairs(t.mixin) do
              assert.same('string', type(k))
              assert.same('function', type(v))
            end
          end)
        end
      end)
    end
  end
end)
