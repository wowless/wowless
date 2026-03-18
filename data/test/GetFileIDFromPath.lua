local T, GetFileIDFromPath = ...
local lite = T.wowless and T.wowless.lite
return {
  addon = function()
    return T.match(1, nil, GetFileIDFromPath('interface/addons/wowless/wowless.toc'))
  end,
  font = function()
    return T.match(1, nil, GetFileIDFromPath('fonts/frizqt__.ttf'))
  end,
  known = function()
    return T.match(1, not lite and 136235 or nil, GetFileIDFromPath('interface/icons/temp.blp'))
  end,
  unknown = function()
    return T.match(1, nil, GetFileIDFromPath('wowlessthisisnotafile.txt'))
  end,
  weirdcase = function()
    return T.match(1, not lite and 136235 or nil, GetFileIDFromPath('INTERFACE\\iCoNs/TEmp.bLP'))
  end,
}
