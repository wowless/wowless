local api = ...
return function(self, ty)
  ty = string.lower(ty)
  if ty == 'object' then
    return self.type ~= 'font'
  else
    return not not api.InheritsFrom(self.type, ty)
  end
end
