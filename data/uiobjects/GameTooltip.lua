return {
  inherits = {'Frame'},
  mixin = {
    AddDoubleLine = UNIMPLEMENTED,
    AddFontStrings = UNIMPLEMENTED,
    AddLine = UNIMPLEMENTED,
    ClearLines = UNIMPLEMENTED,
    FadeOut = UNIMPLEMENTED,
    GetAnchorType = UNIMPLEMENTED,
    GetMinimumWidth = STUB_NUMBER,
    GetOwner = function(self)
      return u(self).tooltipOwner
    end,
    IsOwned = function(self)
      return u(self).tooltipOwner ~= nil
    end,
    NumLines = STUB_NUMBER,
    SetAction = UNIMPLEMENTED,
    SetAnchorType = UNIMPLEMENTED,
    SetBackpackToken = UNIMPLEMENTED,
    SetBagItem = UNIMPLEMENTED,
    SetCurrencyToken = UNIMPLEMENTED,
    SetCurrencyTokenByID = UNIMPLEMENTED,
    SetHyperlink = UNIMPLEMENTED,
    SetInventoryItem = UNIMPLEMENTED,
    SetMinimumWidth = UNIMPLEMENTED,
    SetOwner = function(self, owner)
      u(self).tooltipOwner = owner
    end,
    SetPadding = UNIMPLEMENTED,
    SetShapeshift = UNIMPLEMENTED,
    SetText = UNIMPLEMENTED,
    SetToyByItemID = UNIMPLEMENTED,
    SetUnit = UNIMPLEMENTED,
    SetUnitAura = UNIMPLEMENTED,
    SetUnitBuff = UNIMPLEMENTED,
    SetUnitDebuff = UNIMPLEMENTED,
  },
}
