local products = require('runtime.products')
local args = (function()
  local parser = require('argparse')()
  local run = parser:command('run'):summary('run wowless')
  run:option('-p --product', 'product tag'):count(1):choices(products)
  run:option('-l --loglevel', 'log level', '0'):convert(tonumber)
  run:option('-a --addondir', 'addon directory to test'):count('*')
  run:option('-e --maxerrors', 'quit once this number of errors occur'):convert(tonumber)
  run:option('-s --scripts', 'scripts to execute')
  run:option('-o --output', 'output file')
  run:flag('--allevents', 'send all nullary events')
  run:flag('--frame0', 'write frame0 debug')
  run:flag('--profile', 'dump profile')
  return parser:parse()
end)()
debug.setprofilingenabled(args.profile)
local runner = require('wowless.runner')
local modules = runner.run({
  allevents = args.allevents,
  dir = 'build/cmake/extracts/' .. args.product,
  frame0 = args.frame0,
  loglevel = args.loglevel,
  maxErrors = args.maxerrors,
  otherAddonDirs = args.addondir,
  output = args.output,
  product = args.product,
  scripts = args.scripts,
})
if args.profile then
  require('wowless.profiler').write({
    modules = modules,
    product = args.product,
    runner = runner,
  })
end
