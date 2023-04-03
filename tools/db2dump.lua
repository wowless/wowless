local args = (function()
  local parser = require('argparse')()
  parser:flag('--dbc -d', 'use dbc instead of db2')
  parser:argument('db2file', 'db2file to dump')
  parser:argument('signature', 'luadbc-style type signature')
  return parser:parse()
end)()
local rows = require(args.dbc and 'dbc' or 'wowless.db2').rows
local content = assert(require('pl.file').read(args.db2file))
for row in rows(content, args.signature) do
  print(row[0], unpack(row))
end
