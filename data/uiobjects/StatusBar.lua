return {
  constructor = function(self)
    local ud = u(self)
    ud.max = 0
    ud.min = 0
    ud.value = 0
  end,
  inherits = {'Frame'},
  mixin = {
    GetMinMaxValues = function(self)
      local ud = u(self)
      return ud.min, ud.max
    end,
    GetOrientation = UNIMPLEMENTED,
    GetReverseFill = UNIMPLEMENTED,
    GetRotatesTexture = UNIMPLEMENTED,
    GetStatusBarAtlas = UNIMPLEMENTED,
    GetStatusBarColor = UNIMPLEMENTED,
    GetStatusBarTexture = function(self)
      return u(self).statusBarTexture
    end,
    GetValue = function(self)
      return u(self).value
    end,
    SetMinMaxValues = function(self, min, max)
      local ud = u(self)
      ud.min = min
      ud.max = max
    end,
    SetOrientation = UNIMPLEMENTED,
    SetReverseFill = UNIMPLEMENTED,
    SetRotatesTexture = UNIMPLEMENTED,
    SetStatusBarColor = UNIMPLEMENTED,
    SetStatusBarTexture = function(self, tex)
      if type(tex) == 'number' then
        api.log(1, 'unimplemented call to SetStatusBarTexture')
        u(self).statusBarTexture = m(self, 'CreateTexture')
      else
        u(self).statusBarTexture = toTexture(self, tex)
      end
    end,
    SetValue = function(self, value)
      u(self).value = value
    end,
  },
}
