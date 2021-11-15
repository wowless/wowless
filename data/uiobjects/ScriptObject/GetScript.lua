return (function(self, name, bindingType)
  return u(self).scripts[bindingType or 1][string.lower(name)]
end)(...)
