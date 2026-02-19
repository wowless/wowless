describe('globals', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local globals = require('build.data.products.' .. p .. '.globals')
      describe('enums', function()
        local enums = globals.Enum
        describe('meta', function()
          for k in pairs(enums) do
            describe(k, function()
              if k:sub(-4) == 'Meta' then
                it('has a corresponding real enum', function()
                  assert(enums[k:sub(1, -5)])
                end)
              else
                local meta = assert(enums[k .. 'Meta'])
                it('NumValues matches', function()
                  local count = 0
                  for _ in pairs(enums[k]) do
                    count = count + 1
                  end
                  assert.equal(meta.NumValues, count)
                end)
              end
            end)
          end
        end)
      end)
    end)
  end
end)
