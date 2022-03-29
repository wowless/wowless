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

local rgb565 = vstruct.compile([[
  [ 2 | r: u5 g: u6 b: u5 ]
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
  assert(header.width % 4 == 0)
  assert(header.height % 4 == 0)
  assert(header.mipOffsets[1] == 20 + 64 + 64 + 1024) -- header size
  assert(header.mipSizes[1] == header.width * header.height)
  local rgblines = {}
  for _ = 1, header.height / 4 do
    local lines = { {}, {}, {}, {} }
    for _ = 1, header.width / 4 do
      local t = dxt5:read(f)
      -- Ignore alpha for now, just produce rgb.
      local c2, c3
      if t.c0 > t.c1 then
        c2 = t.c0 * 2 / 3 + t.c1 / 3
        c3 = t.c0 / 3 + t.c1 * 2 / 3
      else
        c2 = t.c0 / 2 + t.c1 / 2
        c3 = 0
      end
      for row = 1, 4 do
        for col = 1, 4 do
          local cx = t.colorTable[(row - 1) * 4 + col]
          local c = cx == 0 and t.c0 or cx == 1 and t.c1 or cx == 2 and c2 or c3
          local rgb = rgb565:read(vstruct.write('u2', '', { c }))
          table.insert(lines[row], string.char(rgb.r * 256 / 32, rgb.g * 256 / 64, rgb.b * 256 / 32))
        end
      end
    end
    for _, line in ipairs(lines) do
      table.insert(rgblines, table.concat(line, ''))
    end
  end
  assert(f:close())
  return header.width, header.height, table.concat(rgblines, '')
end

return {
  read = read,
}
