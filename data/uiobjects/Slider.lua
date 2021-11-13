return {
  constructor = function(self)
    local ud = u(self)
    ud.enabled = true
    ud.max = 0
    ud.min = 0
    ud.value = 0
  end,
  inherits = {'Frame'},
  mixin = {
    Disable = function(self)
      u(self).enabled = false
    end,
    Enable = function(self)
      u(self).enabled = true
    end,
    GetMinMaxValues = function(self)
      local ud = u(self)
      return ud.min, ud.max
    end,
    GetOrientation = UNIMPLEMENTED,
    GetThumbTexture = function(self)
      return u(self).thumbTexture
    end,
    GetValue = function(self)
      return u(self).value
    end,
    IsDraggingThumb = UNIMPLEMENTED,
    IsEnabled = UNIMPLEMENTED,
    SetMinMaxValues = function(self, min, max)
      local ud = u(self)
      ud.min = min
      ud.max = max
    end,
    SetObeyStepOnDrag = UNIMPLEMENTED,
    SetOrientation = UNIMPLEMENTED,
    SetStepsPerPage = UNIMPLEMENTED,
    SetThumbTexture = function(self, tex)
      u(self).thumbTexture = toTexture(self, tex)
    end,
    SetValue = function(self, value)
      u(self).value = value
    end,
    SetValueStep = UNIMPLEMENTED,
  },
}
