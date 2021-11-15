local data = require('tools.scrapelib')(arg[1])
local globals = {
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

local methodsets = {}
for ty, g in pairs(globals) do
  local set = {}
  local ref = data:global()
  for _, part in ipairs(g) do
    ref = data:ref(ref, 's' .. part)
  end
  for m in pairs(data:resolve(data:ref(ref, 'm', 's__index'), 1)) do
    set[m:sub(2)] = true
  end
  methodsets[ty] = set
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

local out = {}
for ty, set in pairs(methodsets) do
  if ty ~= 'Frame' then
    local t = {}
    assert(subset(methodsets.Frame, set))
    for k in pairs(difference(set, methodsets.Frame)) do
      table.insert(t, k)
    end
    table.sort(t)
    out[ty] = t
  end
end

io.write(require('wowapi.yaml').pprint(out))
