local args = (function()
  local parser = require('argparse')()
  parser:argument('input', 'input file')
  parser:option('-o --output', 'output file')
  return parser:parse()
end)()

local parseYaml = require('wowapi.yaml').parseFile
local data = parseYaml(args.input)
local fetch
do
  local build = dofile('runtime/products/' .. data.product .. '/build.lua')
  fetch = require('tactless')(data.product, build.hash)
  if not fetch then
    print('unable to open ' .. build.hash)
    os.exit(1)
  end
end

local out = args.output or require('pl.path').splitext(args.input) .. '.bmp'
print(out)

local parseblp = require('wowless.blp').read
local sdl = require('tools.sdl')

local strata = {
  WORLD = 1,
  BACKGROUND = 2,
  LOW = 3,
  MEDIUM = 4,
  HIGH = 5,
  DIALOG = 6,
  FULLSCREEN = 7,
  FULLSCREEN_DIALOG = 8,
  TOOLTIP = 9,
}

local layers = {
  BACKGROUND = 1,
  BORDER = 2,
  ARTWORK = 3,
  OVERLAY = 4,
  HIGHLIGHT = 5,
}

local surfaces = {}
local function getsurface(path)
  local fpath
  if tonumber(path) then
    fpath = tonumber(path)
  else
    fpath = path:lower():gsub('\\', '/')
    if fpath:sub(-4) ~= '.blp' then
      fpath = fpath .. '.blp'
    end
  end
  local prev = surfaces[fpath]
  if prev then
    return prev
  end
  local content = fetch(fpath)
  local success, surface = pcall(function()
    return sdl.CreateSurfaceFromRGBA(parseblp(content))
  end)
  if success then
    surfaces[fpath] = surface
    return surface
  end
end

table.sort(data.frames, function(a, b)
  local sa = strata[a.strata] or 0
  local sb = strata[b.strata] or 0
  return sa < sb or sa == sb and (a.strataLevel or 0) < (b.strataLevel or 0)
end)
for _, f in ipairs(data.frames) do
  table.sort(f.regions, function(a, b)
    local aa = a.content.texture or {}
    local bb = b.content.texture or {}
    local la = layers[aa.drawLayer] or 0
    local lb = layers[bb.drawLayer] or 0
    return la < lb or la == lb and (aa.drawSubLayer or 0) < (bb.drawSubLayer or 0)
  end)
  for _, v in ipairs(f.regions) do
    if v.content.texture and v.content.texture.drawLayer ~= 'HIGHLIGHT' then
      local r = v.rect
      local left, top, right, bottom = r.left, data.screenHeight - r.top, r.right, data.screenHeight - r.bottom
      local x = v.content.texture.path
      x = x ~= 'FileData ID 0' and x or nil
      if x and left < right and top < bottom then
        getsurface(x)
      end
    end
  end
end
for k, v in pairs(surfaces) do
  v:SaveBMP('asdf_' .. tostring(k):gsub('/', '_') .. '.bmp')
end
