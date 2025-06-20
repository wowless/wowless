local vstruct = require('vstruct')
local zlib = require('zlib')

local function crc32(...)
  local c = zlib.crc32()
  for i = 1, select('#', ...) do
    c = zlib.crc32(c, select(i, ...))
  end
  return c
end

local chunks = {
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

local function toChunk(type, data)
  local str = chunks[type]:write('', data)
  local fmt = ('> u4 s4 s%d u4'):format(#str)
  return vstruct.write(fmt, '', { #str, type, str, crc32(type, str) })
end

local function write(width, height, rgba)
  local t = {}
  table.insert(t, '\137PNG\r\n\26\n')
  table.insert(
    t,
    toChunk('IHDR', {
      width = width,
      height = height,
      bitDepth = 8,
      colorType = 6,
      compressionMethod = 0,
      filterMethod = 0,
      interlaceMethod = 0,
    })
  )
  local lines = {}
  for i = 1, height do
    table.insert(lines, '\0')
    table.insert(lines, rgba:sub((i - 1) * width * 4 + 1, i * width * 4))
  end
  table.insert(t, toChunk('IDAT', { zlib.compress(table.concat(lines)) }))
  table.insert(t, toChunk('IEND', {}))
  return table.concat(t)
end

return {
  write = write,
}
