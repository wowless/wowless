local args = (function()
  local parser = require('argparse')()
  parser:argument('keyfile', 'keyfile.txt')
  parser:argument('output', 'output.lua')
  return parser:parse()
end)()
local wowtxt = require('pl.file').read(args.keyfile)
local t = {}
for line in wowtxt:gmatch('[^\r\n]+') do
  local k, v = line:match('^([0-9A-F]+) ([0-9A-F]+)')
  t[k:lower()] = v:lower()
end
require('pl.file').write(args.output, require('tools.util').returntable(t))
