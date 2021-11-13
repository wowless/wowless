return {
  inherits = {'Frame'},
  mixin = {
    GetColorHSV = function()
      return 0, 0, 0
    end,
    GetColorRGB = function()
      return 0, 0, 0
    end,
    SetColorHSV = UNIMPLEMENTED,
    SetColorRGB = UNIMPLEMENTED,
    SetColorWheelTexture = UNIMPLEMENTED,
    SetColorWheelThumbTexture = UNIMPLEMENTED,
  },
}
