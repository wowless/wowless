local crc32lib = require('crc32')
local vstruct = require('vstruct')

local blpHeader = vstruct.compile([[
  magic: s4  -- BLP2
  version: u4  -- 1
  colorEncoding: u1
  alphaSize: u1
  pixelFormat: u1
  hasMips: u1
  width: u4
  height: u4
  mipOffsets: { 16*u4 }
  mipSizes: { 16*u4 }
  palette: { 256*u4 }
]])

local dxt5 = vstruct.compile([[
  a0: u1
  a1: u1
  alphaTable: { [ 6 | 16*u3 ] }
  c0: u2
  c1: u2
  colorTable: { [ 4 | 16*u2 ] }
]])

local function parseBLP(filename)
  local f = assert(io.open(filename))
  local header = blpHeader:read(f)
  assert(header.magic == 'BLP2')
  assert(header.version == 1)
  assert(header.colorEncoding == 2) -- DXT
  assert(header.alphaSize == 8)
  assert(header.pixelFormat == 7) -- DXT5
  assert(header.hasMips == 17)
  assert(header.width == header.height)
  do
    local cur = 20 + 64 + 64 + 1024 -- header size
    local dim = header.width
    for i = 1, math.log(dim) do
      assert(header.mipOffsets[i] == cur)
      assert(header.mipSizes[i] == dim * dim)
      for _ = 1, dim * dim / 16 do
        require('pl.pretty').dump(dxt5:read(f))
      end
      cur = cur + dim * dim
      dim = dim / 2
    end
  end
  assert(f:close())
end

--[[
local function adler32(...)
  local a, b = 1, 0
  for i = 1, select('#', ...) do
    local s = select(i, ...)
    for j = 1, #s do
      local c = s:sub(j, j):byte()
      a = (a + c) % 65521
      b = (b + a) % 65521
    end
  end
  return bit.bor(bit.lshift(b, 16), a)
end
]]

local function crc32(...)
  local c = crc32lib.newcrc32()
  for i = 1, select('#', ...) do
    c:update(select(i, ...))
  end
  return c:tonumber()
end

local pngChunks = {
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

local function writePNG(filename)
  local f = assert(io.open(filename, 'wb'))
  assert(f:write('\137PNG\r\n\26\n'))
  writePNGChunk(f, 'IHDR', {
    width = 1,
    height = 1,
    bitDepth = 8,
    colorType = 2,
    compressionMethod = 0,
    filterMethod = 0,
    interlaceMethod = 0,
  })
  assert(f:close())
end

parseBLP('temp.blp')
writePNG('temp.png')
