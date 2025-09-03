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

local screensurface = sdl.CreateSurface(data.screenWidth, data.screenHeight)
local renderer = screensurface:CreateSoftwareRenderer()

local textures = {}
local function gettexture(path)
  local fpath
  if tonumber(path) then
    fpath = tonumber(path)
  else
    fpath = path:lower():gsub('\\', '/')
    if fpath:sub(-4) ~= '.blp' then
      fpath = fpath .. '.blp'
    end
  end
  local prev = textures[fpath]
  if prev then
    return prev
  end
  local content = fetch(fpath)
  local success, texture = pcall(function()
    local surface = sdl.CreateSurface(parseblp(content))
    return renderer:CreateTextureFromSurface(surface)
  end)
  if success then
    textures[fpath] = texture
    return texture
  else
    print('womp ' .. tostring(texture))
  end
end

local function render(region)
  local tex = region.content.texture
  if not tex or tex.alpha <= 0 or tex.drawLayer == 'HIGHLIGHT' then
    return
  end
  local path = tex.path
  if not path or path == 'FileData ID 0' then
    return
  end
  local rect = region.rect
  local left = rect.left
  local top = data.screenHeight - rect.top
  local right = rect.right
  local bottom = data.screenHeight - rect.bottom
  if left >= right or top >= bottom then
    return
  end
  local sdltex = gettexture(path)
  if not sdltex then
    return
  end
  local c = tex.coords
  renderer:RenderGeometry(sdltex, {
    { px = left, py = top, tx = c.tlx, ty = c.tly },
    { px = left, py = bottom, tx = c.blx, ty = c.bly },
    { px = right, py = top, tx = c.trx, ty = c.try },
    { px = right, py = bottom, tx = c.brx, ty = c.bry },
  }, { 1, 2, 3, 2, 3, 4 })
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
  for _, region in ipairs(f.regions) do
    render(region)
  end
end
renderer:RenderPresent()
local out = args.output or require('pl.path').splitext(args.input) .. '.bmp'
screensurface:SaveBMP(out)
print(out)
