describe('xml', function()
  local scripttypes = require('build.data.scripttypes')
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      for name, elem in pairs(require('build.data.products.' .. p .. '.xml')) do
        if elem.extends == 'ScriptType' then
          it(name .. ' is in scripttypes', function()
            assert.Not.Nil(scripttypes[name])
          end)
        end
      end
    end)
  end
end)
