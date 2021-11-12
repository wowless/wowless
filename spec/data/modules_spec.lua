describe('modules', function()
  for filename in require('lfs').dir('data/modules') do
    if filename ~= '.' and filename ~= '..' then
      describe(filename, function()
        assert(filename:sub(-4) == '.lua', 'invalid file ' .. filename)
        local module = assert(loadfile('data/modules/' .. filename))()
        it('returns a valid table', function()
          assert.same('table', type(module))
          assert.Nil(getmetatable(module))
          local fields = {
            api = true,
            state = true,
          }
          for k in pairs(module) do
            assert.True(fields[k], ('unexpected field %q'):format(k))
          end
          assert.Not.Nil(module.api)
          assert.same('table', type(module.api))
          assert.Nil(getmetatable(module.api))
          for k, v in pairs(module.api) do
            assert.same('string', type(k))
            assert.Not.same('', k)
            assert.same('function', type(v))
          end
          assert.True(module.state == nil or type(module.state) == 'table')
        end)
      end)
    end
  end
end)
