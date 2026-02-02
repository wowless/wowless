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
                it('has a corresponding meta enum', function()
                  assert(enums[k .. 'Meta'])
                end)
              end
            end)
          end
        end)
      end)
    end)
  end
end)
