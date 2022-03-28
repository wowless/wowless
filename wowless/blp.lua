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
  local f = io.open(filename)
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
  f:close()
end

parseBLP('temp.blp')
