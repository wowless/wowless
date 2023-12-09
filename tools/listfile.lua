local args = (function()
  local parser = require('argparse')()
  parser:argument('manifest', 'manifest.json')
  parser:argument('output', 'output.lua')
  return parser:parse()
end)()
local t = {}
local listfile = require('pl.file').read(args.manifest)
for _, e in ipairs(require('cjson').decode(listfile)) do
  local id = e.db2FileDataID
  if id then
    t[e.tableName:lower()] = tonumber(id)
  end
end
require('pl.file').write(args.output, require('tools.util').returntable(t))
