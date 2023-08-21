local t = {}
local listfile = require('pl.file').read('vendor/dbdefs/manifest.json')
for _, e in ipairs(require('cjson').decode(listfile)) do
  local id = e.db2FileDataID
  if id then
    t[e.tableName:lower()] = tonumber(id)
  end
end

local u = require('tools.util')
u.writeifchanged('build/listfile.lua', u.returntable(t))
