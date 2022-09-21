local require = require
_G.require = function(k, ...)
  assert(k:sub(1, 6) ~= 'tools.')
  assert(k ~= 'wowapi.yaml')
  return require(k, ...)
end
local util = require('wowless.util')
local args = (function()
  local parser = require('argparse')()
  parser:option('-p --product', 'product tag'):count(1):choices(util.productList())
  parser:option('-l --loglevel', 'log level', '0'):convert(tonumber)
  parser:option('-a --addondir', 'addon directory to test'):count('*')
  parser:option('-c --cascproxy', 'url prefix to cascproxy')
  parser:option('-e --maxerrors', 'quit once this number of errors occur'):convert(tonumber)
  parser:option('-s --scripts', 'scripts to execute')
  parser:flag('--allevents', 'send all nullary events')
  parser:flag('--debug', 'enter debug mode after load')
  parser:flag('--frame0', 'write frame0 debug')
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
  otherAddonDirs = args.addondir,
  product = args.product,
  scripts = args.scripts,
})
if api.GetErrorCount() ~= 0 then
  io.stderr:write('failure on ' .. args.product .. '\n')
  os.exit(1)
end
