local args = (function()
  local parser = require('argparse')()
  parser:flag('--dbc -d', 'use dbc instead of db2')
  parser:argument('product', 'product')
  parser:argument('db2', 'db2')
  return parser:parse()
end)()
local rows = require(args.dbc and 'dbc' or 'wowless.db2').rows
local dbdefs = dofile('build/products/' .. args.product .. '/dbdefs.lua')
local db2file = 'extracts/' .. args.product .. '/db2/' .. args.db2 .. '.db2'
local content = assert(require('pl.file').read(db2file))
for row in rows(content, '{' .. dbdefs[args.db2].sig .. '}') do
  print(row[0], unpack(row))
end
