describe('events', function()
  for _, p in ipairs(require('build.data.products')) do
    local wapi = require('wowless.api').new(function() end, 0, p, 0)
    local typechecker = require('wowless.typecheck')(wapi)
    describe(p, function()
      for name, event in pairs(require('build.data.products.' .. p .. '.events')) do
        describe(name, function()
          it('elements are uniquely named', function()
            local names = {}
            for _, arg in ipairs(event.payload) do
              assert.Nil(names[arg.name])
              names[arg.name] = true
            end
          end)
          for _, arg in ipairs(event.payload) do
            describe(arg.name, function()
              if arg.default ~= nil then
                it('default must typecheck', function()
                  local value, errmsg = typechecker(arg, arg.default, true)
                  assert.Nil(errmsg)
                  assert.same(value, arg.default)
                end)
              end
            end)
          end
          if event.stride ~= nil then
            it('has a valid stride', function()
              assert.True(event.stride <= #event.payload)
            end)
          end
        end)
      end
    end)
  end
end)
