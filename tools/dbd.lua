local dblist = require('tools.dblist')
local dbds = require('luadbd').dbds
local ret = {}
local builds = require('wowapi.yaml').parseFile('data/builds.yaml')
for product, build in pairs(builds) do
  for _, db in ipairs(dblist(product)) do
    db = db:lower()
    local dbd = dbds[db]
    local v = (function()
      for _, version in ipairs(dbd.versions) do
        for _, vb in ipairs(version.builds) do
          if #vb == 1 and table.concat(vb[1], '.') == build.version .. '.' .. build.build then
            return version
          end
        end
      end
      error('cannot find build ' .. build.version .. ' for product ' .. product)
    end)()
    if not ret[dbd.name] then
      ret[dbd.name] = {
        fdid = dbd.fdid,
        name = dbd.name,
        versions = {
          {
            fields = v.fields,
            products = { product },
            sig = v.sig,
          },
        },
      }
    else
      local mine = {
        fields = v.fields,
        sig = v.sig,
      }
      local match = nil
      for _, x in ipairs(ret[dbd.name].versions) do
        local theirs = {
          fields = x.fields,
          sig = x.sig,
        }
        if require('pl.tablex').deepcompare(mine, theirs) then
          match = x
        end
      end
      if match then
        table.insert(match.products, product)
        table.sort(match.products)
      else
        table.insert(ret[dbd.name].versions, {
          fields = v.fields,
          products = { product },
          sig = v.sig,
        })
      end
    end
  end
end
do
  local p = require('wowapi.yaml').pprint
  local w = require('pl.file').write
  for _, v in pairs(ret) do
    w('data/dbdefs/' .. v.name .. '.yaml', p(v))
  end
end
