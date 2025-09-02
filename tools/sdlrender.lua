local args = (function()
  local parser = require('argparse')()
  parser:argument('input', 'input file')
  parser:option('-o --output', 'output file')
  return parser:parse()
end)()

local parseYaml = require('wowapi.yaml').parseFile
local data = parseYaml(args.input)
local fetch
do
  local build = dofile('runtime/products/' .. data.product .. '/build.lua')
  fetch = require('tactless')(data.product, build.hash)
  if not fetch then
    print('unable to open ' .. build.hash)
    os.exit(1)
  end
end

local out = args.output or require('pl.path').splitext(args.input) .. '.bmp'
print(out)

local readfile = require('pl.file').read
local parseblp = require('wowless.blp').read
local sdl = require('tools.sdl')
sdl.CreateSurfaceFromRGBA(parseblp(readfile('../../spec/wowless/temp.blp'))):SaveBMP(out)
