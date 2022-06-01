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

require('pl.file').write(
  'addon/Wowless/generated.lua',
  assert(plsub(
    [[
local _, G = ...
local assertEquals = _G.assertEquals
local GetObjectType = CreateFrame('Frame').GetObjectType
G.GeneratedTestFailures = G.test(function(t)
  t.scope('frametype', function()
> for k, v in sorted(frametypes) do
    t.scope('$(k)', function()
> if cfgs[k].flavors then
      if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_MAINLINE then
        assertEquals(
          false,
          pcall(function()
            CreateFrame('$(k)')
          end)
        )
        return
      end
> end
      local frame = CreateFrame('$(k)')
      assert(frame)
> if k == 'EditBox' then
      frame:Hide() -- captures input focus otherwise
> end
      assertEquals('$(objTypes[k])', GetObjectType(frame))
    end)
> end
  end)
end)
]],
    {
      _escape = '>',
      cfgs = cfgs,
      frametypes = frametypes,
      objTypes = objTypes,
      sorted = require('pl.tablex').sort,
    }
  ))
)
