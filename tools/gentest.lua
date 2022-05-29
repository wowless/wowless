local plsub = require('pl.template').substitute

local cfgs = {}
do
  local lfs = require('lfs')
  local yaml = require('wowapi.yaml')
  for d in lfs.dir('data/uiobjects') do
    if d ~= '.' and d ~= '..' then
      local filename = ('data/uiobjects/%s/%s.yaml'):format(d, d)
      local cfg = yaml.parseFile(filename)
      cfgs[cfg.name] = cfg
    end
  end
end

local inhrev = {}
for _, cfg in pairs(cfgs) do
  for _, inh in ipairs(cfg.inherits) do
    inhrev[inh] = inhrev[inh] or {}
    table.insert(inhrev[inh], cfg.name)
  end
end

local objTypes = {}
for _, cfg in pairs(cfgs) do
  objTypes[cfg.name] = cfg.objectType or cfg.name
end

local frametypes = {}
do
  local function addtype(ty)
    if not frametypes[ty] then
      frametypes[ty] = true
      for _, inh in ipairs(inhrev[ty] or {}) do
        addtype(inh)
      end
    end
  end
  addtype('Frame')
end

-- TODO figure out the right approach for these
frametypes.Minimap = nil
frametypes.WorldFrame = nil

-- TODO teach wowless that POIFrame is virtual and retail-only
frametypes.QuestPOIFrame = nil
frametypes.ScenarioPOIFrame = nil

require('pl.file').write(
  'addon/Wowless/generated.lua',
  assert(plsub(
    [[
local _, G = ...
local assertEquals = _G.assertEquals
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
> if k ~= 'FogOfWarFrame' then
      assertEquals('$(objTypes[k])', frame:GetObjectType())
> end
    end,
  },
> end
}
]],
    {
      _escape = '>',
      frametypes = frametypes,
      objTypes = objTypes,
      sorted = require('pl.tablex').sort,
    }
  ))
)
