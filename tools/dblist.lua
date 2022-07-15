local product = ...
local dbset = {
  globalstrings = true,
  manifestinterfacetocdata = true,
}
for _, v in pairs(require('wowapi.data').apis) do
  local products = {}
  for _, f in ipairs(v.products or {}) do
    products[f] = true
  end
  if not v.products or products[product] then
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
