local vstruct = require('vstruct')
local zlib = require('zlib')

local function crc32(...)
  local c = zlib.crc32()
  for i = 1, select('#', ...) do
    c = zlib.crc32(c, select(i, ...))
  end
  return c
end

local pngChunks = {
  IDAT = vstruct.compile('s'),
  IEND = vstruct.compile(''),
  IHDR = vstruct.compile([[>
    width: u4
    height: u4
    bitDepth: u1
    colorType: u1
    compressionMethod: u1
    filterMethod: u1
    interlaceMethod: u1
  ]]),
}

local function writePNGChunk(f, type, data)
  local str = pngChunks[type]:write('', data)
  local fmt = ('> u4 s4 s%d u4'):format(#str)
  vstruct.write(fmt, f, { #str, type, str, crc32(type, str) })
end

local function writePNG(filename, width, height, data)
  local f = assert(io.open(filename, 'wb'))
  assert(f:write('\137PNG\r\n\26\n'))
  writePNGChunk(f, 'IHDR', {
    width = width,
    height = height,
    bitDepth = 8,
    colorType = 2,
    compressionMethod = 0,
    filterMethod = 0,
    interlaceMethod = 0,
  })
  local lines = {}
  for i = 1, height do
    table.insert(lines, '\0')
    table.insert(lines, data:sub((i - 1) * width * 3 + 1, i * width * 3))
  end
  writePNGChunk(f, 'IDAT', { zlib.compress(table.concat(lines, '')) })
  writePNGChunk(f, 'IEND', {})
  assert(f:close())
end

writePNG(
  'temp.png',
  256,
  256,
  (function()
    local t = {}
    for i = 0, 255 do
      table.insert(t, string.char(0, i, 0):rep(256))
    end
    return table.concat(t, '')
  end)()
)
