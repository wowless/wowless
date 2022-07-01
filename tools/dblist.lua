local product = ...
local flavor = require('wowless.util').productToFlavor(product)
local dbset = {
  globalstrings = true,
  manifestinterfacetocdata = true,
}
for _, v in pairs(require('wowapi.data').apis) do
  local flavors = {}
  for _, f in ipairs(v.flavors or { 'Vanilla', 'TBC', 'Mainline' }) do
    flavors[f] = true
  end
  if flavors[flavor] then
    for _, db in ipairs(v.dbs or {}) do
      dbset[db.name] = true
    end
  end
end
local dblist = {}
for db in pairs(dbset) do
  table.insert(dblist, db)
end
table.sort(dblist)
for _, db in ipairs(dblist) do
  print(db)
end
