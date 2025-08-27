local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product')
  parser:argument('db2', 'db2')
  return parser:parse()
end)()
local rows = require('tools.db2').rows
local dbdefs = dofile('build/cmake/runtime/' .. args.product .. '_dbdefs.lua')
local db2file = 'extracts/' .. args.product .. '/db2/' .. args.db2 .. '.db2'
local content = assert(require('pl.file').read(db2file))
local dbdef = dbdefs[args.db2]
for row in rows(content, dbdef) do
  print(unpack(row, 1, #dbdef))
end
