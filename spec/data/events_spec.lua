describe('events', function()
  for _, p in ipairs(require('build.data.products')) do
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
        end)
      end
    end)
  end
end)
