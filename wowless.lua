local productToFlavor = {
  wow = 'Mainline',
  wowt = 'Mainline',
  wow_classic = 'TBC',
  wow_classic_era = 'Vanilla',
  wow_classic_era_ptr = 'Vanilla',
  wow_classic_ptr = 'TBC',
}
local args = (function()
  local parser = require('argparse')()
  parser:option('--loglevel', 'log level')
  parser:option('--product', 'product tag')
  parser:option('--addondir', 'addon directory to test')
  parser:flag('--allevents', 'send all nullary events')
  parser:argument('deprecated_loglevel', 'log level'):default('0')
  parser:argument('deprecated_product', 'product tag'):default('wow_classic')
  parser:argument('deprecated_flavor', 'product flavor'):default('TBC')
  parser:argument('deprecated_addon', 'addon directory to test'):args('?')
  return parser:parse()
end)()
local product = args.product or args.deprecated_product
local api = require('wowless.runner').run({
  loglevel = assert(tonumber(args.loglevel or args.deprecated_loglevel)),
  dir = 'extracts/' .. product,
  version = (args.product and productToFlavor[args.product] or args.deprecated_flavor),
  otherAddonDirs = { args.addondir or args.deprecated_addon },
  allevents = args.allevents,
})
if api.GetErrorCount() ~= 0 then
  io.stderr:write('failure on ' .. product .. '\n')
  os.exit(1)
end
