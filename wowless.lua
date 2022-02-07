local args = (function()
  local parser = require('argparse')()
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
})
if api.GetErrorCount() ~= 0 then
  io.stderr:write('failure on ' .. args.tag .. '\n')
  os.exit(1)
end
