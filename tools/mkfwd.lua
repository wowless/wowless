local args = (function()
  local parser = require('argparse')()
  parser:flag('--alias')
  parser:argument('name')
  parser:argument('impl'):args('?')
  return parser:parse()
end)()
local n = args.name
local nn = args.impl or args.name
local w = require('pl.file').write
local f = string.format
if args.alias then
  w(f('data/api/%s.yaml', n), f('---\nname: %s\nalias: %s\n', n, nn))
else
  w(f('data/api/%s.yaml', n), f('---\nname: %s\nstatus: implemented\n', n))
  w(f('data/impl/%s.lua', n), f('return %s(...)\n', nn))
end
