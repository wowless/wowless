local args = (function()
  local parser = require('argparse')()
  parser:argument('input', 'input file')
  parser:option('-o --output', 'output file')
  parser:flag('-v --verbose', 'verbose')
  return parser:parse()
end)()

local parseYaml = require('wowapi.yaml').parseFile

local data = parseYaml(args.input)

local fetch = (function()
  local build = dofile('runtime/products/' .. data.product .. '/build.lua')
  local fetch = require('tactless')(data.product, build.hash)
  if not fetch then
    print('unable to open ' .. build.hash)
    os.exit(1)
  end
  return fetch
end)()

local out = args.output or require('pl.path').splitext(args.input) .. '.png'
require('wowless.render').rects2png(data, fetch, out)
