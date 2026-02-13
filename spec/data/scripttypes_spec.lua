describe('scripttypes', function()
  local scripttypes = require('build.data.scripttypes')
  local products = require('build.data.products')
  local used = {}
  for _, p in ipairs(products) do
    for _, obj in pairs(require('build.data.products.' .. p .. '.uiobjects')) do
      if obj.scripts then
        for name in pairs(obj.scripts) do
          used[name] = true
        end
      end
    end
  end
  for name in pairs(scripttypes) do
    it(name .. ' is used in some uiobjects.yaml', function()
      assert.Not.Nil(used[name])
    end)
  end
end)
