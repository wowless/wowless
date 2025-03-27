describe('wowless.toc', function()
  local wowlesstoc = require('wowless.toc')
  local flavors = require('runtime.flavors')
  describe('suffixes', function()
    local allsuffixes = wowlesstoc.suffixes
    it('are keyed by flavor', function()
      for k in pairs(allsuffixes) do
        assert.Not.Nil(flavors[k])
      end
    end)
    for flavor in pairs(flavors) do
      describe(flavor, function()
        local suffixes = allsuffixes[flavor]
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
    end
  end)
end)
