local uiobjecttypes = ...
return function(self, ty)
  ty = string.lower(ty)
  if ty == 'object' then
    return self.type ~= 'font'
  else
    return not not uiobjecttypes.InheritsFrom(self.type, ty)
  end
end
