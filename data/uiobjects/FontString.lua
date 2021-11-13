return {
  inherits = {'FontInstance', 'LayeredRegion'},
  mixin = {
    GetLineHeight = STUB_NUMBER,
    GetNumLines = STUB_NUMBER,
    GetStringHeight = STUB_NUMBER,
    GetStringWidth = STUB_NUMBER,
    GetUnboundedStringWidth = STUB_NUMBER,
    GetText = function(self)
      return u(self).text
    end,
    GetWrappedWidth = STUB_NUMBER,
    IsTruncated = UNIMPLEMENTED,
    SetFormattedText = UNIMPLEMENTED,
    SetMaxLines = UNIMPLEMENTED,
    SetNonSpaceWrap = UNIMPLEMENTED,
    SetText = function(self, text)
      if type(text) == 'number' then
        text = tostring(text)
      end
      u(self).text = type(text) == 'string' and text or nil
    end,
    SetTextHeight = UNIMPLEMENTED,
    SetWordWrap = UNIMPLEMENTED,
  },
}
