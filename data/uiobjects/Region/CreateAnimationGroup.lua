return (function(self)
  local group = api.CreateUIObject('animationgroup')
  table.insert(u(self).animationGroups, group)
  return group
end)(...)
