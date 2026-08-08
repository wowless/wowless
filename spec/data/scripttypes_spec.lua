describe('scripttypes', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local scripttypes = require('build.data.products.' .. p .. '.scripttypes')
      local used = {}
      for _, obj in pairs(require('build.data.products.' .. p .. '.uiobjects')) do
        if obj.scripts then
          for name in pairs(obj.scripts) do
            used[name] = true
          end
        end
      end
      for name in pairs(scripttypes) do
        it(name .. ' is used in some uiobjects.yaml', function()
          assert.Not.Nil(used[name])
        end)
      end
    end)
  end
end)
