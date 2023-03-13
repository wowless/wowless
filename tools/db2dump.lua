local args = (function()
  local parser = require('argparse')()
  parser:argument('db2file', 'db2file to dump')
  parser:argument('signature', 'luadbc-style type signature')
  return parser:parse()
end)()
local db2 = require('wowless.db2')
local content = assert(require('pl.file').read(args.db2file))
for row in db2.rows(content, args.signature) do
  print(row[0], unpack(row))
end
