return {
  inherits = {'Frame'},
  mixin = {
    GetLightDirection = function()
      return 1, 1, 1  -- UNIMPLEMENTED
    end,
    GetLightPosition = function()
      return 1, 1, 1  -- UNIMPLEMENTED
    end,
    GetViewInsets = function()
      return 1, 1, 1, 1  -- UNIMPLEMENTED
    end,
    SetLightAmbientColor = UNIMPLEMENTED,
    SetLightDirection = UNIMPLEMENTED,
    SetLightPosition = UNIMPLEMENTED,
    SetViewInsets = UNIMPLEMENTED,
  },
}
