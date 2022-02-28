local productToFlavor = {
  wow = 'Mainline',
  wowt = 'Mainline',
  wow_classic = 'TBC',
  wow_classic_era = 'Vanilla',
  wow_classic_era_ptr = 'Vanilla',
  wow_classic_ptr = 'TBC',
}
local products = (function()
  local t = {}
  for k in pairs(productToFlavor) do
    table.insert(t, k)
  end
  return t
end)()
local args = (function()
  local parser = require('argparse')()
  parser:option('-p --product', 'product tag'):count(1):choices(products)
  parser:option('-l --loglevel', 'log level', 0):convert(tonumber)
  parser:option('-a --addondir', 'addon directory to test'):count('*')
  parser:flag('--allevents', 'send all nullary events')
  parser:flag('--slashcmds', 'send all slash commands with empty args')
  return parser:parse()
end)()
local api = require('wowless.runner').run({
  allevents = args.allevents,
  dir = 'extracts/' .. args.product,
  loglevel = args.loglevel,
  otherAddonDirs = args.addondir,
  slashcmds = args.slashcmds,
  version = productToFlavor[args.product],
})
if api.GetErrorCount() ~= 0 then
  io.stderr:write('failure on ' .. args.product .. '\n')
  os.exit(1)
end
