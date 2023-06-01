local args
local require = require
_G.require = function(k, ...)
  assert(k:sub(1, 6) ~= 'tools.')
  assert(k ~= 'wowapi.yaml' or args.frame0)
  return require(k, ...)
end
local util = require('wowless.util')
args = (function()
  local parser = require('argparse')()
  parser:option('-p --product', 'product tag'):count(1):choices(util.productList())
  parser:option('-l --loglevel', 'log level', '0'):convert(tonumber)
  parser:option('-a --addondir', 'addon directory to test'):count('*')
  parser:option('-e --maxerrors', 'quit once this number of errors occur'):convert(tonumber)
  parser:option('-s --scripts', 'scripts to execute')
  parser:flag('--allevents', 'send all nullary events')
  parser:flag('--debug', 'enter debug mode after load')
  parser:flag('--frame0', 'write frame0 debug')
  parser:flag('--profile', 'dump profile')
  return parser:parse()
end)()
debug.setprofilingenabled(args.profile)
local runner = require('wowless.runner')
local api, loader = runner.run({
  allevents = args.allevents,
  debug = args.debug,
  dir = 'extracts/' .. args.product,
  frame0 = args.frame0,
  loglevel = args.loglevel,
  maxErrors = args.maxerrors,
  otherAddonDirs = args.addondir,
  product = args.product,
  scripts = args.scripts,
})
if args.profile then
  local mark = {}
  local function getfuncstats(t)
    if mark[t] then
      return
    end
    mark[t] = true
    local tt = {}
    for k, v in pairs(t) do
      if type(k) == 'string' then
        if type(v) == 'function' then
          tt[k] = debug.getfunctionstats(v)
        elseif type(v) == 'table' then
          local tv = getfuncstats(v)
          if tv and next(tv) then
            tt[k] = tv
          end
        end
      end
    end
    return tt
  end
  local t = {
    api = getfuncstats(api),
    loader = getfuncstats(loader),
    runner = getfuncstats(runner),
  }
  local fn = 'profile.' .. args.product .. '.yaml'
  local content = require('wowapi.yaml').pprint(t)
  require('pl.file').write(fn, content)
end
