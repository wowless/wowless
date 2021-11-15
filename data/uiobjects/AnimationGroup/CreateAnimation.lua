return (function(self, type)
  local ltype = (type or 'animation'):lower()
  assert(api.InheritsFrom(ltype, 'animation'))
  local anim = api.CreateUIObject(ltype)
  table.insert(u(self).animations, anim)
  return anim
end)(...)
