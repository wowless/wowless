local uiobjecttypes = ...
return function(self)
  return uiobjecttypes.GetOrThrow(self.type).name
end
