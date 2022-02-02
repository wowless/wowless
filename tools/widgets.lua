local scraper = require('tools.scrapelib')
local versions = {
  Vanilla = scraper(arg[1]),
  TBC = scraper(arg[2]),
  Mainline = scraper(arg[3]),
}

local globals = {
  Button = { 'SpellBookNextPageButton' },
  Checkout = { 'SimpleCheckout' },
  ColorSelect = { 'ColorPickerFrame' },
  Cooldown = { 'ContainerFrame1Item1Cooldown' },
  Frame = { 'ActionStatus' },
  GameTooltip = { 'GameTooltip' },
  Minimap = { 'Minimap' },
  ModelScene = { 'ModelPreviewFrame', 'Display', 'ModelScene' },
  MovieFrame = { 'MovieFrame' },
  --  OffScreenFrame = { 'OffScreenFrame' },
  Slider = { 'OpacitySliderFrame' },
  StatusBar = { 'PlayerFrameHealthBar' },
  --  SimpleHTML = 'ItemTextPageText',
  WorldFrame = { 'WorldFrame' },
}

local function methodsets(data)
  local result = {}
  for ty, g in pairs(globals) do
    local set = {}
    local ref = data:global()
    for _, part in ipairs(g) do
      ref = data:ref(ref, 's' .. part)
    end
    for m in pairs(data:resolve(data:ref(ref, 'm', 's__index'), 1)) do
      set[m:sub(2)] = true
    end
    result[ty] = set
  end
  return result
end

local function subset(set1, set2)
  for k in pairs(set1) do
    if not set2[k] then
      return false
    end
  end
  return true
end

local function difference(set1, set2)
  local t = {}
  for k in pairs(set1) do
    if not set2[k] then
      t[k] = true
    end
  end
  return t
end

local function typemethods(ms)
  local out = {}
  for ty, set in pairs(ms) do
    if ty ~= 'Frame' then
      local t = {}
      assert(subset(ms.Frame, set))
      for k in pairs(difference(set, ms.Frame)) do
        table.insert(t, k)
      end
      table.sort(t)
      out[ty] = t
    end
  end
  return out
end

local clsinfo = (function()
  local out = {}
  local function process(name, version)
    for k, v in pairs(typemethods(methodsets(version))) do
      out[k] = out[k] or {}
      for _, m in ipairs(v) do
        out[k][m] = out[k][m] or {}
        out[k][m][name] = true
      end
    end
  end
  for k, v in pairs(versions) do
    process(k, v)
  end
  return out
end)()

local existing = require('wowapi.data').uiobjects
for name, obj in pairs(existing) do
  if clsinfo[name] then
    for m, vers in pairs(clsinfo[name]) do
      local all = true
      for k in pairs(versions) do
        all = all and vers[k]
      end
      obj.cfg.methods[m] = obj.cfg.methods[m] or { status = 'unimplemented' }
      if not all then
        local vs = {}
        for v in pairs(vers) do
          table.insert(vs, v)
        end
        obj.cfg.methods[m].versions = vs
      end
    end
    local fn = ('data/uiobjects/%s/%s.yaml'):format(name, name)
    local yaml = require('wowapi.yaml').pprint(obj.cfg)
    require('pl.file').write(fn, yaml)
  end
end
