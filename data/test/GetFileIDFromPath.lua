local T = ...
local lite = T.wowless and T.wowless.lite
return {
  addon = function()
    return T.match(1, nil, T.env.GetFileIDFromPath('interface/addons/wowless/wowless.toc'))
  end,
  font = function()
    return T.match(1, nil, T.env.GetFileIDFromPath('fonts/frizqt__.ttf'))
  end,
  known = function()
    return T.match(1, not lite and 136235 or nil, T.env.GetFileIDFromPath('interface/icons/temp.blp'))
  end,
  unknown = function()
    return T.match(1, nil, T.env.GetFileIDFromPath('wowlessthisisnotafile.txt'))
  end,
  weirdcase = function()
    return T.match(1, not lite and 136235 or nil, T.env.GetFileIDFromPath('INTERFACE\\iCoNs/TEmp.bLP'))
  end,
}
