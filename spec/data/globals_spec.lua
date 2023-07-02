describe('globals', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local globals = require('build.data.products.' .. p .. '.globals')
      describe('enums', function()
        local enums = globals.Enum
        describe('meta', function()
          for k in pairs(enums) do
            if k:sub(-4) == 'Meta' then
              describe(k, function()
                it('has a corresponding real enum', function()
                  assert(enums[k:sub(1, -5)])
                end)
              end)
            end
          end
        end)
      end)
    end)
  end
end)
