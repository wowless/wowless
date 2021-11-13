return {
  inherits = {'Frame'},
  mixin = {
    GetHorizontalScroll = STUB_NUMBER,
    GetVerticalScrollRange = STUB_NUMBER,
    GetScrollChild = function(self)
      return u(self).scrollChild
    end,
    SetHorizontalScroll = UNIMPLEMENTED,
    SetScrollChild = function(self, scrollChild)
      u(self).scrollChild = scrollChild
    end,
    SetVerticalScroll = UNIMPLEMENTED,
    UpdateScrollChildRect = UNIMPLEMENTED,
  },
}
