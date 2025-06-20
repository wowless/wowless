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

local dxt1 = vstruct.compile([[
  c0: { [ 2 | r: u5 g: u6 b: u5 ] }
  c1: { [ 2 | r: u5 g: u6 b: u5 ] }
  colorTable: { [ 4 | 16*u2 ] }
]])

local dxt3 = vstruct.compile([[
  alphaTable: { [ 8 | 16*u4 ] }
  c0: { [ 2 | r: u5 g: u6 b: u5 ] }
  c1: { [ 2 | r: u5 g: u6 b: u5 ] }
  colorTable: { [ 4 | 16*u2 ] }
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
  local c2 = (c0 * 2 + c1) / 3
  local c3 = (c0 + c1 * 2) / 3
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

local function dxt1rgba(c0, c1)
  local r2 = (c0.r + c1.r) / 2
  local g2 = (c0.g + c1.g) / 2
  local b2 = (c0.b + c1.b) / 2
  return {
    [0] = dxt1scale(c0),
    [1] = dxt1scale(c1),
    [2] = dxt1scale({ r = r2, g = g2, b = b2 }),
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

local function rundxt(header, fn)
  local rgbalines = {}
  for _ = 1, header.height / 4 do
    local lines = { {}, {}, {}, {} }
    for _ = 1, header.width / 4 do
      local perPixel = fn()
      for row = 1, 4 do
        for col = 1, 4 do
          local idx = 17 - ((row - 1) * 4 + col)
          local rgb, a = perPixel(idx)
          table.insert(lines[row], string.char(rgb.r, rgb.g, rgb.b, a))
        end
      end
    end
    for _, line in ipairs(lines) do
      table.insert(rgbalines, table.concat(line))
    end
  end
  return table.concat(rgbalines)
end

local pixelFormats = {
  [0] = function(f, header) -- DXT1
    assert(header.mipSizes[1] == header.width * header.height / 2)
    if header.alphaSize == 0 then
      return rundxt(header, function()
        local t = dxt1:read(f)
        local cc = dxt1rgb(t.c0, t.c1)
        return function(idx)
          return cc[t.colorTable[idx]], 255
        end
      end)
    elseif header.alphaSize == 1 then
      local black = { r = 0, g = 0, b = 0 }
      return rundxt(header, function()
        local t = dxt1:read(f)
        local cc = dxt1rgba(t.c0, t.c1)
        return function(idx)
          local cx = t.colorTable[idx]
          if cx == 3 then
            return black, 0
          else
            return cc[cx], 255
          end
        end
      end)
    else
      error('invalid alpha size ' .. header.alphaSize)
    end
  end,
  [1] = function(f, header) -- DXT3
    assert(header.alphaSize == 4 or header.alphaSize == 8)
    assert(header.mipSizes[1] == header.width * header.height)
    return rundxt(header, function()
      local t = dxt3:read(f)
      local cc = dxt1rgb(t.c0, t.c1)
      return function(idx)
        return cc[t.colorTable[idx]], t.alphaTable[idx] * 16
      end
    end)
  end,
  [7] = function(f, header) -- DXT5
    assert(header.alphaSize == 8)
    assert(header.mipSizes[1] == header.width * header.height)
    return rundxt(header, function()
      local t = dxt5:read(f)
      local aa = dxt5alpha(t.a0, t.a1)
      local cc = dxt1rgb(t.c0, t.c1)
      return function(idx)
        return cc[t.colorTable[idx]], aa[t.alphaTable[idx]]
      end
    end)
  end,
}

local function read(bytes)
  local f = vstruct.cursor(bytes)
  local header = blpHeader:read(f)
  assert(header.magic == 'BLP2')
  assert(header.version == 1)
  assert(header.colorEncoding == 2) -- DXT
  assert(header.hasMips == 0 or header.hasMips == 1 or header.hasMips == 17)
  assert(header.width % 4 == 0)
  assert(header.height % 4 == 0)
  assert(header.mipOffsets[1] == 20 + 64 + 64 + 1024) -- header size
  local rgba = assert(pixelFormats[header.pixelFormat])(f, header)
  return header.width, header.height, rgba
end

return {
  read = read,
}
