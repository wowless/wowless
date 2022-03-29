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

local function read(filename)
  local f = assert(io.open(filename))
  local header = blpHeader:read(f)
  assert(header.magic == 'BLP2')
  assert(header.version == 1)
  assert(header.colorEncoding == 2) -- DXT
  assert(header.alphaSize == 8)
  assert(header.pixelFormat == 7) -- DXT5
  assert(header.hasMips == 17)
  assert(header.mipOffsets[1] == 20 + 64 + 64 + 1024) -- header size
  assert(header.mipSizes[1] == header.width * header.height)
  for _ = 1, header.width * header.height / 16 do
    dxt5:read(f)
  end
  assert(f:close())
  return header.width, header.height
end

return {
  read = read,
}
