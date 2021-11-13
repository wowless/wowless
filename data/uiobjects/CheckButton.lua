return {
  constructor = function(self)
    u(self).checked = false
  end,
  inherits = {'Button'},
  mixin = {
    GetChecked = function(self)
      return u(self).checked
    end,
    GetCheckedTexture = function(self)
      return u(self).checkedTexture
    end,
    GetDisabledCheckedTexture = function(self)
      return u(self).disabledCheckedTexture
    end,
    SetChecked = function(self, checked)
      u(self).checked = not not checked
    end,
    SetCheckedTexture = function(self, tex)
      u(self).checkedTexture = toTexture(self, tex)
    end,
    SetDisabledCheckedTexture = function(self, tex)
      u(self).disabledCheckedTexture = toTexture(self, tex)
    end,
  },
}
