local args = (function()
  local parser = require('argparse')()
  parser:argument('input', 'input file')
  parser:option('-o --output', 'output file')
  parser:flag('-v --verbose', 'verbose')
  return parser:parse()
end)()

local parseYaml = require('wowapi.yaml').parseFile

local data = parseYaml(args.input)

local casc = (function()
  local encryptionKeys = (function()
    local wowtxt = require('pl.file').read('vendor/tactkeys/WoW.txt')
    local ret = {}
    for line in wowtxt:gmatch('[^\r\n]+') do
      local k, v = line:match('^([0-9A-F]+) ([0-9A-F]+)')
      ret[k:lower()] = v:lower()
    end
    return ret
  end)()
  local build = parseYaml('data/products/' .. data.product .. '/build.yaml')
  local lib = require('casc')
  local _, cdn, ckey = lib.cdnbuild('http://us.patch.battle.net:1119/' .. data.product, 'us')
  local handle, err = lib.open({
    bkey = build.hash,
    cache = 'cache',
    cacheFiles = true,
    cdn = cdn,
    ckey = ckey,
    keys = encryptionKeys,
    locale = lib.locale.US,
    log = args.verbose and print or nil,
    zerofillEncryptedChunks = true,
  })
  if not handle then
    print('unable to open ' .. build.hash .. ': ' .. err)
    os.exit(1)
  end
  return handle
end)()

local out = args.output or require('pl.path').splitext(args.input) .. '.png'
require('wowless.render').rects2png(data, casc, out)
