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
  c0: { [ 2 | r: u5 g: u6 b: u5 ] }
  c1: { [ 2 | r: u5 g: u6 b: u5 ] }
  colorTable: { [ 4 | 16*u2 ] }
]])

local function dxt1color(c0, c1)
  local c2, c3
  if c0 > c1 then
    c2 = (c0 * 2 + c1) / 3
    c3 = (c0 + c1 * 2) / 3
  else
    c2 = (c0 + c1) / 2
    c3 = 0
  end
  return c2, c3
end

local function dxt1scale(c)
  return {
    r = c.r * 256 / 32,
    g = c.g * 256 / 64,
    b = c.b * 256 / 32,
  }
end

local function dxt1rgb(c0, c1)
  local r2, r3 = dxt1color(c0.r, c1.r)
  local g2, g3 = dxt1color(c0.g, c1.g)
  local b2, b3 = dxt1color(c0.b, c1.b)
  return {
    [0] = dxt1scale(c0),
    [1] = dxt1scale(c1),
    [2] = dxt1scale({ r = r2, g = g2, b = b2 }),
    [3] = dxt1scale({ r = r3, g = g3, b = b3 }),
  }
end

local function dxt5alpha(a0, a1)
  if a0 > a1 then
    return {
      [0] = a0,
      [1] = a1,
      [2] = (6 * a0 + 1 * a1) / 7,
      [3] = (5 * a0 + 2 * a1) / 7,
      [4] = (4 * a0 + 3 * a1) / 7,
      [5] = (3 * a0 + 4 * a1) / 7,
      [6] = (2 * a0 + 5 * a1) / 7,
      [7] = (1 * a0 + 6 * a1) / 7,
    }
  else
    return {
      [0] = a0,
      [1] = a1,
      [2] = (4 * a0 + 1 * a1) / 7,
      [3] = (3 * a0 + 2 * a1) / 7,
      [4] = (2 * a0 + 3 * a1) / 7,
      [5] = (1 * a0 + 4 * a1) / 7,
      [6] = 0,
      [7] = 255,
    }
  end
end

local function read(filename)
  local f = assert(io.open(filename))
  local header = blpHeader:read(f)
  assert(header.magic == 'BLP2')
  assert(header.version == 1)
  assert(header.colorEncoding == 2) -- DXT
  assert(header.alphaSize == 8)
  assert(header.pixelFormat == 7) -- DXT5
  assert(header.hasMips == 1 or header.hasMips == 17)
  assert(header.width % 4 == 0)
  assert(header.height % 4 == 0)
  assert(header.mipOffsets[1] == 20 + 64 + 64 + 1024) -- header size
  assert(header.mipSizes[1] == header.width * header.height)
  local rgblines = {}
  for _ = 1, header.height / 4 do
    local lines = { {}, {}, {}, {} }
    for _ = 1, header.width / 4 do
      local t = dxt5:read(f)
      local cc = dxt1rgb(t.c0, t.c1)
      local aa = dxt5alpha(t.a0, t.a1)
      for row = 1, 4 do
        for col = 1, 4 do
          local idx = 17 - ((row - 1) * 4 + col)
          local a = aa[t.alphaTable[idx]]
          local rgb = cc[t.colorTable[idx]]
          table.insert(lines[row], string.char(rgb.r, rgb.g, rgb.b, a))
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
