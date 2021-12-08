local dbset = {
  globalstrings = true,
}
for _, v in pairs(require('wowapi.data').apis) do
  for _, db in ipairs(v.dbs or {}) do
    dbset[db] = true
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
