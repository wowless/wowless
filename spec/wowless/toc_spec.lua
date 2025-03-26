describe('wowless.toc', function()
  local wowlesstoc = require('wowless.toc')
  for flavor in pairs(require('runtime.flavors')) do
    describe(flavor, function()
      local tocutil = wowlesstoc(flavor)
      describe('suffixes', function()
        local suffixes = tocutil.suffixes
        it('are unique', function()
          local t = {}
          for _, v in ipairs(suffixes) do
            assert.Nil(t[v])
            t[v] = true
          end
        end)
        it('have the empty string as the last member', function()
          assert.same('', suffixes[#suffixes])
        end)
      end)
    end)
  end
end)
