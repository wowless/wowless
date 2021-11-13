return {
  constructor = function(self)
    u(self).editboxText = ''
    u(self).enabled = true
    u(self).isAutoFocus = true
    u(self).isCountInvisibleLetters = false
    u(self).isMultiLine = false
    u(self).maxLetters = 64  -- TODO validate this default
  end,
  inherits = {'FontInstance', 'Frame'},
  mixin = {
    AddHistoryLine = UNIMPLEMENTED,
    ClearFocus = UNIMPLEMENTED,
    Disable = function(self)
      u(self).enabled = false
    end,
    Enable = function(self)
      u(self).enabled = true
    end,
    GetInputLanguage = function()
      return 'ROMAN'  -- UNIMPLEMENTED
    end,
    GetMaxLetters = function(self)
      return u(self).maxLetters
    end,
    GetNumber = STUB_NUMBER,
    GetText = function(self)
      return u(self).editboxText
    end,
    IsAutoFocus = function(self)
      return u(self).isAutoFocus
    end,
    IsCountInvisibleLetters = function(self)
      return u(self).isCountInvisibleLetters
    end,
    IsEnabled = function(self)
      return u(self).enabled
    end,
    IsMultiLine = function(self)
      return u(self).isMultiLine
    end,
    SetAltArrowKeyMode = UNIMPLEMENTED,
    SetAutoFocus = function(self, value)
      u(self).isAutoFocus = not not value
    end,
    SetCountInvisibleLetters = function(self, value)
      u(self).isCountInvisibleLetters = not not value
    end,
    SetEnabled = function(self, value)
      u(self).enabled = not not value
    end,
    SetFocus = UNIMPLEMENTED,
    SetMaxLetters = function(self, value)
      u(self).maxLetters = value
    end,
    SetMultiLine = function(self, value)
      u(self).isMultiLine = not not value
    end,
    SetNumber = UNIMPLEMENTED,
    SetNumeric = UNIMPLEMENTED,
    SetSecureText = function(self, text)
      u(self).editboxText = text
    end,
    SetSecurityDisablePaste = UNIMPLEMENTED,
    SetSecurityDisableSetText = UNIMPLEMENTED,
    SetText = function(self, text)
      u(self).editboxText = text
    end,
    SetTextInsets = UNIMPLEMENTED,
  },
}
