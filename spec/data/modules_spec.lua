describe('modules', function()
  local state = require('wowapi.data').state
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
          assert.same('function', type(module.api))
          if module.state ~= nil then
            assert.same('table', type(module.state))
            for _, v in ipairs(module.state) do
              assert.same('string', type(v))
              assert.Not.Nil(state[v])
            end
          end
        end)
        local args = {}
        for _, v in ipairs(module.state or {}) do
          table.insert(args, state[v].value)
        end
        for fname, fn in pairs(module.api(unpack(args))) do
          describe(fname, function()
            it('has a valid name', function()
              assert.same('string', type(fname))
              assert.Not.same('', fname)
            end)
            it('has a valid function', function()
              assert.same('function', type(fn))
            end)
          end)
        end
      end)
    end
  end
end)
