local args = (function()
  local parser = require('argparse')()
  parser:flag('--allevents', 'send all nullary events')
  parser:argument('loglevel', 'log level'):default('0')
  parser:argument('product', 'product tag'):default('wow_classic')
  parser:argument('flavor', 'product flavor'):default('TBC')
  parser:argument('addon', 'addon directory to test'):args('?')
  return parser:parse()
end)()
local api = require('wowless.runner').run({
  loglevel = assert(tonumber(args.loglevel)),
  dir = 'extracts/' .. args.product,
  version = args.flavor,
  otherAddonDirs = { args.addon },
  allevents = args.allevents,
})
if api.GetErrorCount() ~= 0 then
  io.stderr:write('failure on ' .. args.product .. '\n')
  os.exit(1)
end
