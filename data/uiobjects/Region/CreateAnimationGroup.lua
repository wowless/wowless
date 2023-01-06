return (function(self)
  local group = api.CreateUIObject('animationgroup', nil, self)
  table.insert(u(self).animationGroups, group)
  return group
end)(...)
