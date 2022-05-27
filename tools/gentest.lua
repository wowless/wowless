local lfs = require('lfs')
local yaml = require('wowapi.yaml')
local plsub = require('pl.template').substitute

local inhrev = {}
for d in lfs.dir('data/uiobjects') do
  if d ~= '.' and d ~= '..' then
    local filename = ('data/uiobjects/%s/%s.yaml'):format(d, d)
    local cfg = yaml.parseFile(filename)
    for _, inh in ipairs(cfg.inherits) do
      inhrev[inh] = inhrev[inh] or {}
      table.insert(inhrev[inh], cfg.name)
    end
  end
end

local frametypes = {}
local function addtype(ty)
  if not frametypes[ty] then
    frametypes[ty] = true
    for _, inh in ipairs(inhrev[ty] or {}) do
      addtype(inh)
    end
  end
end
addtype('Frame')

-- TODO figure out the right approach for these
frametypes.Minimap = nil
frametypes.WorldFrame = nil

-- TODO teach wowless that POIFrame is virtual and retail-only
frametypes.POIFrame = nil
frametypes.QuestPOIFrame = nil
frametypes.ScenarioPOIFrame = nil

print((assert(plsub(
  [[
local _, G = ...
G.WowlessGeneratedTests = {
> for k, v in sorted(frametypes) do
  {
    name = 'can CreateFrame $(k)',
    fn = function()
      local frame = CreateFrame('$(k)')
      assert(frame)
> if k == 'EditBox' then
      frame:Hide()
> end
> if k ~= 'Checkout' and k ~= 'FogOfWarFrame' then
      assertEquals('$(k)', frame:GetObjectType())
> end
    end,
  },
> end
}]],
  {
    _escape = '>',
    frametypes = frametypes,
    sorted = require('pl.tablex').sort,
  }
))))
