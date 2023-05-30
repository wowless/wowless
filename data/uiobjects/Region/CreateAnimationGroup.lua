return (function(self)
  local group = api.CreateUIObject('animationgroup', nil, self)
  table.insert(self.animationGroups, group)
  return group.luarep
end)(...)
