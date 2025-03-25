describe('wowless.toc', function()
  local wowlesstoc = require('wowless.toc')
  for flavor in pairs(require('runtime.flavors')) do
    describe(flavor, function()
      local tocutil = wowlesstoc(flavor)
      describe('resolve', function()
        local resolve = tocutil.resolve
        it('wowless addon', function()
          local file, content = resolve('addon/Wowless')
          assert.same('addon/Wowless/Wowless.toc', file)
          assert.Not.Nil(content)
        end)
      end)
    end)
  end
end)
