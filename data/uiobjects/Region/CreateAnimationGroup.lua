return (function(self)
  local group = api.CreateUIObject('animationgroup', nil, self.luarep)
  table.insert(self.animationGroups, group)
  return group
end)(...)
