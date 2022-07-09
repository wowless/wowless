local dbds = require('luadbd').dbds
local join = require('path').join
local read = require('pl.file').read
local dump = require('pl.pretty').dump

local args = (function()
  local parser = require('argparse')()
  parser:argument('build', 'build')
  parser:argument('dbname', 'db name')
  return parser:parse()
end)()

local version = args.build
local db = args.dbname
local dbd = dbds[db]
local build = assert(dbd:build(version), ('cannot load %s in %s'):format(db, version))
local t = {}
for row in build:rows(read(join('extracts', version, 'db2', db .. '.db2'))) do
  table.insert(t, row)
end
dump(t)
