-- Don't let casc use any system backdoors.
os.execute = function(...) -- luacheck: ignore
  error('attempt to call execute(' .. table.concat({ ... }) .. ')')
end
local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:flag('-v --verbose', 'verbose')
  return parser:parse()
end)()
local product = args.product
local log = args.verbose and print or function() end
local cmap = dofile('build/products/' .. product .. '/cmap.lua')
local path = require('path')
path.mkdir('cache')
local outdir = path.join('extracts2', product)
if path.isdir(outdir) then
  require('pl.dir').rmtree(outdir)
end
local fetch = (function()
  local http = require('socket.http').request
  local tsink = require('ltn12').sink.table
  local blte = require('casc.blte').readData
  local opts = { zerofillEncryptedChunks = true }
  return function(v)
    local h = v.archive
    local suffix = ('%s/%s/%s'):format(h:sub(1, 2), h:sub(3, 4), h)
    local url = 'http://blzddist1-a.akamaihd.net/tpr/wow/data/' .. suffix
    local sink = {}
    local ok, status = http({
      headers = {
        Range = 'bytes=' .. v.rstart .. '-' .. v.rend,
      },
      sink = tsink(sink),
      url = url,
    })
    assert(ok, url)
    assert(status == 206, status .. ' ' .. url)
    return (blte(table.concat(sink), nil, opts))
  end
end)()
for k, v in require('pl.tablex').sort(cmap) do
  log('writing', k)
  path.mkdir(path.dirname(path.join(outdir, k)))
  require('pl.file').write(path.join(outdir, k), fetch(v))
end
