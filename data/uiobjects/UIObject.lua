return {
  inherits = {},
  mixin = {
    GetName = function(self)
      return u(self).name
    end,
    GetObjectType = function(self)
      return api.uiobjectTypes[u(self).type].name
    end,
    IsObjectType = function(self, ty)
      return api.InheritsFrom(u(self).type, string.lower(ty))
    end,
  },
}
