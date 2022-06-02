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

local function badflavor(flavors)
  local ids = {
    Mainline = 'WOW_PROJECT_MAINLINE',
    TBC = 'WOW_PROJECT_BURNING_CRUSADE_CLASSIC',
    Vanilla = 'WOW_PROJECT_CLASSIC',
  }
  if #flavors == 1 then
    return 'WOW_PROJECT_ID ~= ' .. assert(ids[flavors[1]])
  elseif #flavors == 2 then
    assert(ids[flavors[1]])
    ids[flavors[1]] = nil
    assert(ids[flavors[2]])
    ids[flavors[2]] = nil
    local _, v = next(ids)
    return 'WOW_PROJECT_ID == ' .. v
  else
    error('invalid flavor setting')
  end
end

-- TODO figure out the right approach for these
cfgs.Minimap = nil
cfgs.WorldFrame = nil

require('pl.file').write(
  'addon/Wowless/generated.lua',
  assert(plsub(
    [[
local _, G = ...
local assertEquals = _G.assertEquals
local GetObjectType = CreateFrame('Frame').GetObjectType
G.GeneratedTestFailures = G.test(function()
  return {
    uiobjects = function()
      local function assertCreateFrame(ty)
        local function process(...)
          assertEquals(1, select('#', ...))
          local frame = ...
          assert(type(frame) == 'table')
          return frame
        end
        return process(CreateFrame(ty))
      end
      local function assertCreateFrameFails(ty)
        local success, err = pcall(function()
          CreateFrame(ty)
        end)
        assert(not success)
        local expectedErr = 'CreateFrame: Unknown frame type \'' .. ty .. '\''
        assertEquals(expectedErr, err:sub(err:len() - expectedErr:len() + 1))
      end
      return {
> for k, v in sorted(cfgs) do
        $(k) = function()
> if frametypes[k] and v.flavors then
          if $(badflavor(v.flavors)) then
            assertCreateFrameFails('$(k)')
            return
          end
> end
> if frametypes[k] then
          local frame = assertCreateFrame('$(k)')
          local frame2 = assertCreateFrame('$(k)')
> if k == 'EditBox' then
          frame:Hide() -- captures input focus otherwise
          frame2:Hide() -- captures input focus otherwise
> end
          assertEquals('$(objTypes[k])', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
> if k ~= 'FogOfWarFrame' then
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
> if next(v.methods) then
            methods = function()
              return {
> for mname, method in sorted(v.methods) do
                $(mname) = function()
> if method.flavors then
                  if $(badflavor(method.flavors)) then
                    assertEquals('nil', type(mt.__index.$(mname)))
                    return
                  end
> end
                  assertEquals('function', type(mt.__index.$(mname)))
                end,
> end
              }
            end,
> end
          }
> end
> else
          assertCreateFrameFails('$(k)')
> end
        end,
> end
      }
    end,
  }
end)
]],
    {
      _escape = '>',
      badflavor = badflavor,
      cfgs = cfgs,
      frametypes = frametypes,
      next = next,
      objTypes = objTypes,
      sorted = require('pl.tablex').sort,
    }
  ))
)
