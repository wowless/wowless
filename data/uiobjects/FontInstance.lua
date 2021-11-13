return {
  inherits = {'UIObject'},
  mixin = {
    GetFont = function()
      return nil, 12  -- UNIMPLEMENTED
    end,
    GetShadowColor = function()
      return 1, 1, 1  -- UNIMPLEMENTED
    end,
    GetShadowOffset = STUB_NUMBER,
    GetSpacing = STUB_NUMBER,
    GetTextColor = function()
      return 1, 1, 1  -- UNIMPLEMENTED
    end,
    SetFont = UNIMPLEMENTED,
    SetFontObject = UNIMPLEMENTED,
    SetIndentedWordWrap = UNIMPLEMENTED,
    SetJustifyH = UNIMPLEMENTED,
    SetJustifyV = UNIMPLEMENTED,
    SetShadowColor = UNIMPLEMENTED,
    SetShadowOffset = UNIMPLEMENTED,
    SetSpacing = UNIMPLEMENTED,
    SetTextColor = UNIMPLEMENTED,
  },
}
