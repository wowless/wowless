local util = require('wowless.util')
local args = (function()
  local parser = require('argparse')()
  parser:option('-p --product', 'product tag'):count(1):choices(util.productList())
  parser:option('-l --loglevel', 'log level', '0'):convert(tonumber)
  parser:option('-a --addondir', 'addon directory to test'):count('*')
  parser:option('-c --cascproxy', 'url prefix to cascproxy')
  parser:option('-e --maxerrors', 'quit once this number of errors occur'):convert(tonumber)
  parser:flag('--allevents', 'send all nullary events')
  parser:flag('--debug', 'enter debug mode after load')
  parser:flag('--frame0', 'write frame0 debug')
  parser:flag('--taint', 'support taint handling')
  return parser:parse()
end)()
local api = require('wowless.runner').run({
  allevents = args.allevents,
  cascproxy = args.cascproxy,
  debug = args.debug,
  dir = 'extracts/' .. args.product,
  frame0 = args.frame0,
  loglevel = args.loglevel,
  maxErrors = args.maxerrors,
  taint = args.taint,
  otherAddonDirs = args.addondir,
  version = util.productToFlavor(args.product),
})
if api.GetErrorCount() ~= 0 then
  io.stderr:write('failure on ' .. args.product .. '\n')
  os.exit(1)
end
