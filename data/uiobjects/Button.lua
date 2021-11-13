return {
  constructor = function(self)
    u(self).beingClicked = false
    u(self).buttonLocked = false
    u(self).buttonState = 'NORMAL'
    u(self).enabled = true
    u(self).motionScriptsWhileDisabled = false
    u(self).pushedTextOffsetX = 0
    u(self).pushedTextOffsetY = 0
    u(self).registeredClicks = { LeftButtonUp = true }
  end,
  inherits = {'Frame'},
  mixin = {
    Click = function(self, button, down)
      local ud = u(self)
      if ud.enabled and not ud.beingClicked then
        ud.beingClicked = true
        local b = button or 'LeftButton'
        api.RunScript(self, 'PreClick', b, down)
        api.RunScript(self, 'OnClick', b, down)
        api.RunScript(self, 'PostClick', b, down)
        ud.beingClicked = false
      end
    end,
    Disable = function(self)
      u(self).enabled = false
    end,
    Enable = function(self)
      u(self).enabled = true
    end,
    GetButtonState = function(self)
      return u(self).buttonState
    end,
    GetDisabledTexture = function(self)
      return u(self).disabledTexture
    end,
    GetFontString = function(self)
      local fs = u(self).fontstring
      return fs and u(fs).parent == self and fs or nil
    end,
    GetHighlightTexture = function(self)
      return u(self).highlightTexture
    end,
    GetMotionScriptsWhileDisabled = function(self)
      return u(self).motionScriptsWhileDisabled
    end,
    GetNormalTexture = function(self)
      return u(self).normalTexture
    end,
    GetPushedTextOffset = function(self)
      return u(self).pushedTextOffsetX, u(self).pushedTextOffsetY
    end,
    GetPushedTexture = function(self)
      return u(self).pushedTexture
    end,
    GetText = function(self)
      local fs = u(self).fontstring
      return fs and u(fs).parent == self and m(fs, 'GetText') or nil
    end,
    GetTextHeight = STUB_NUMBER,
    GetTextWidth = STUB_NUMBER,
    IsEnabled = function(self)
      return u(self).enabled
    end,
    LockHighlight = UNIMPLEMENTED,
    RegisterForClicks = function(self, ...)
      local ud = u(self)
      util.twipe(ud.registeredClicks)
      for _, type in ipairs({...}) do
        ud.registeredClicks[type] = true
      end
    end,
    SetButtonState = function(self, state, locked)
      u(self).buttonLocked = not not locked
      u(self).buttonState = state
    end,
    SetDisabledAtlas = function(self, atlas)
      u(self).disabledTexture = toTexture(self, atlas)
    end,
    SetDisabledFontObject = UNIMPLEMENTED,
    SetDisabledTexture = function(self, tex)
      u(self).disabledTexture = toTexture(self, tex)
    end,
    SetEnabled = function(self, value)
      u(self).enabled = not not value
    end,
    SetFontString = function(self, value)
      u(u(value).parent).fontstring = nil
      api.SetParent(value, self)
      u(self).fontstring = value
    end,
    SetFormattedText = UNIMPLEMENTED,
    SetHighlightAtlas = function(self, atlas)
      u(self).highlightTexture = toTexture(self, atlas)
    end,
    SetHighlightFontObject = UNIMPLEMENTED,
    SetHighlightTexture = function(self, tex)
      u(self).highlightTexture = toTexture(self, tex)
    end,
    SetMotionScriptsWhileDisabled = function(self, value)
      u(self).motionScriptsWhileDisabled = not not value
    end,
    SetNormalAtlas = function(self, atlas)
      u(self).normalTexture = toTexture(self, atlas)
    end,
    SetNormalFontObject = UNIMPLEMENTED,
    SetNormalTexture = function(self, tex)
      u(self).normalTexture = toTexture(self, tex)
    end,
    SetPushedAtlas = function(self, atlas)
      u(self).pushedTexture = toTexture(self, atlas)
    end,
    SetPushedTextOffset = function(self, x, y)
      u(self).pushedTextOffsetX = x
      u(self).pushedTextOffsetY = y
    end,
    SetPushedTexture = function(self, tex)
      u(self).pushedTexture = toTexture(self, tex)
    end,
    SetText = function(self, text)
      u(self).fontstring = u(self).fontstring or m(self, 'CreateFontString')
      m(u(self).fontstring, 'SetText', text)
    end,
    UnlockHighlight = UNIMPLEMENTED,
  },
}
