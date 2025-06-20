return function(self, name, bindingType)
  return self.scripts[bindingType or 1][string.lower(name)]
end
