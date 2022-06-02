local _, G = ...
local assertEquals = _G.assertEquals
local GetObjectType = CreateFrame('Frame').GetObjectType
G.GeneratedTestFailures = G.test(function()
  return {
    uiobjects = function()
      local function assertCreateFrame(ty)
        local function process(...)
          assertEquals(1, select('#', ...))
          local frame = ...
          assert(type(frame) == 'table')
          return frame
        end
        return process(CreateFrame(ty))
      end
      local function assertCreateFrameFails(ty)
        local success, err = pcall(function()
          CreateFrame(ty)
        end)
        assert(not success)
        local expectedErr = 'CreateFrame: Unknown frame type \'' .. ty .. '\''
        assertEquals(expectedErr, err:sub(err:len() - expectedErr:len() + 1))
      end
      return {
        Actor = function()
          assertCreateFrameFails('Actor')
        end,
        Alpha = function()
          assertCreateFrameFails('Alpha')
        end,
        Animation = function()
          assertCreateFrameFails('Animation')
        end,
        AnimationGroup = function()
          assertCreateFrameFails('AnimationGroup')
        end,
        Browser = function()
          local frame = assertCreateFrame('Browser')
          local frame2 = assertCreateFrame('Browser')
          assertEquals('Browser', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                NavigateHome = function()
                  assertEquals('function', type(mt.__index.NavigateHome))
                end,
              }
            end,
          }
        end,
        Button = function()
          local frame = assertCreateFrame('Button')
          local frame2 = assertCreateFrame('Button')
          assertEquals('Button', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                Click = function()
                  assertEquals('function', type(mt.__index.Click))
                end,
                Disable = function()
                  assertEquals('function', type(mt.__index.Disable))
                end,
                Enable = function()
                  assertEquals('function', type(mt.__index.Enable))
                end,
                GetButtonState = function()
                  assertEquals('function', type(mt.__index.GetButtonState))
                end,
                GetDisabledFontObject = function()
                  assertEquals('function', type(mt.__index.GetDisabledFontObject))
                end,
                GetDisabledTexture = function()
                  assertEquals('function', type(mt.__index.GetDisabledTexture))
                end,
                GetFontString = function()
                  assertEquals('function', type(mt.__index.GetFontString))
                end,
                GetHighlightFontObject = function()
                  assertEquals('function', type(mt.__index.GetHighlightFontObject))
                end,
                GetHighlightTexture = function()
                  assertEquals('function', type(mt.__index.GetHighlightTexture))
                end,
                GetMotionScriptsWhileDisabled = function()
                  assertEquals('function', type(mt.__index.GetMotionScriptsWhileDisabled))
                end,
                GetNormalFontObject = function()
                  assertEquals('function', type(mt.__index.GetNormalFontObject))
                end,
                GetNormalTexture = function()
                  assertEquals('function', type(mt.__index.GetNormalTexture))
                end,
                GetPushedTextOffset = function()
                  assertEquals('function', type(mt.__index.GetPushedTextOffset))
                end,
                GetPushedTexture = function()
                  assertEquals('function', type(mt.__index.GetPushedTexture))
                end,
                GetText = function()
                  assertEquals('function', type(mt.__index.GetText))
                end,
                GetTextHeight = function()
                  assertEquals('function', type(mt.__index.GetTextHeight))
                end,
                GetTextWidth = function()
                  assertEquals('function', type(mt.__index.GetTextWidth))
                end,
                IsEnabled = function()
                  assertEquals('function', type(mt.__index.IsEnabled))
                end,
                LockHighlight = function()
                  assertEquals('function', type(mt.__index.LockHighlight))
                end,
                RegisterForClicks = function()
                  assertEquals('function', type(mt.__index.RegisterForClicks))
                end,
                RegisterForMouse = function()
                  assertEquals('function', type(mt.__index.RegisterForMouse))
                end,
                SetButtonState = function()
                  assertEquals('function', type(mt.__index.SetButtonState))
                end,
                SetDisabledAtlas = function()
                  assertEquals('function', type(mt.__index.SetDisabledAtlas))
                end,
                SetDisabledFontObject = function()
                  assertEquals('function', type(mt.__index.SetDisabledFontObject))
                end,
                SetDisabledTexture = function()
                  assertEquals('function', type(mt.__index.SetDisabledTexture))
                end,
                SetEnabled = function()
                  assertEquals('function', type(mt.__index.SetEnabled))
                end,
                SetFontString = function()
                  assertEquals('function', type(mt.__index.SetFontString))
                end,
                SetFormattedText = function()
                  assertEquals('function', type(mt.__index.SetFormattedText))
                end,
                SetHighlightAtlas = function()
                  assertEquals('function', type(mt.__index.SetHighlightAtlas))
                end,
                SetHighlightFontObject = function()
                  assertEquals('function', type(mt.__index.SetHighlightFontObject))
                end,
                SetHighlightTexture = function()
                  assertEquals('function', type(mt.__index.SetHighlightTexture))
                end,
                SetMotionScriptsWhileDisabled = function()
                  assertEquals('function', type(mt.__index.SetMotionScriptsWhileDisabled))
                end,
                SetNormalAtlas = function()
                  assertEquals('function', type(mt.__index.SetNormalAtlas))
                end,
                SetNormalFontObject = function()
                  assertEquals('function', type(mt.__index.SetNormalFontObject))
                end,
                SetNormalTexture = function()
                  assertEquals('function', type(mt.__index.SetNormalTexture))
                end,
                SetPushedAtlas = function()
                  assertEquals('function', type(mt.__index.SetPushedAtlas))
                end,
                SetPushedTextOffset = function()
                  assertEquals('function', type(mt.__index.SetPushedTextOffset))
                end,
                SetPushedTexture = function()
                  assertEquals('function', type(mt.__index.SetPushedTexture))
                end,
                SetText = function()
                  assertEquals('function', type(mt.__index.SetText))
                end,
                UnlockHighlight = function()
                  assertEquals('function', type(mt.__index.UnlockHighlight))
                end,
              }
            end,
          }
        end,
        CheckButton = function()
          local frame = assertCreateFrame('CheckButton')
          local frame2 = assertCreateFrame('CheckButton')
          assertEquals('CheckButton', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetChecked = function()
                  assertEquals('function', type(mt.__index.GetChecked))
                end,
                GetCheckedTexture = function()
                  assertEquals('function', type(mt.__index.GetCheckedTexture))
                end,
                GetDisabledCheckedTexture = function()
                  assertEquals('function', type(mt.__index.GetDisabledCheckedTexture))
                end,
                SetChecked = function()
                  assertEquals('function', type(mt.__index.SetChecked))
                end,
                SetCheckedTexture = function()
                  assertEquals('function', type(mt.__index.SetCheckedTexture))
                end,
                SetDisabledCheckedTexture = function()
                  assertEquals('function', type(mt.__index.SetDisabledCheckedTexture))
                end,
              }
            end,
          }
        end,
        Checkout = function()
          local frame = assertCreateFrame('Checkout')
          local frame2 = assertCreateFrame('Checkout')
          assertEquals('BlizzardCheckout', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
          }
        end,
        CinematicModel = function()
          local frame = assertCreateFrame('CinematicModel')
          local frame2 = assertCreateFrame('CinematicModel')
          assertEquals('CinematicModel', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                SetFacingLeft = function()
                  assertEquals('function', type(mt.__index.SetFacingLeft))
                end,
                SetHeightFactor = function()
                  assertEquals('function', type(mt.__index.SetHeightFactor))
                end,
                SetTargetDistance = function()
                  assertEquals('function', type(mt.__index.SetTargetDistance))
                end,
              }
            end,
          }
        end,
        ColorSelect = function()
          local frame = assertCreateFrame('ColorSelect')
          local frame2 = assertCreateFrame('ColorSelect')
          assertEquals('ColorSelect', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetColorHSV = function()
                  assertEquals('function', type(mt.__index.GetColorHSV))
                end,
                GetColorRGB = function()
                  assertEquals('function', type(mt.__index.GetColorRGB))
                end,
                GetColorValueTexture = function()
                  assertEquals('function', type(mt.__index.GetColorValueTexture))
                end,
                GetColorValueThumbTexture = function()
                  assertEquals('function', type(mt.__index.GetColorValueThumbTexture))
                end,
                GetColorWheelTexture = function()
                  assertEquals('function', type(mt.__index.GetColorWheelTexture))
                end,
                GetColorWheelThumbTexture = function()
                  assertEquals('function', type(mt.__index.GetColorWheelThumbTexture))
                end,
                SetColorHSV = function()
                  assertEquals('function', type(mt.__index.SetColorHSV))
                end,
                SetColorRGB = function()
                  assertEquals('function', type(mt.__index.SetColorRGB))
                end,
                SetColorValueTexture = function()
                  assertEquals('function', type(mt.__index.SetColorValueTexture))
                end,
                SetColorValueThumbTexture = function()
                  assertEquals('function', type(mt.__index.SetColorValueThumbTexture))
                end,
                SetColorWheelTexture = function()
                  assertEquals('function', type(mt.__index.SetColorWheelTexture))
                end,
                SetColorWheelThumbTexture = function()
                  assertEquals('function', type(mt.__index.SetColorWheelThumbTexture))
                end,
              }
            end,
          }
        end,
        ControlPoint = function()
          assertCreateFrameFails('ControlPoint')
        end,
        Cooldown = function()
          local frame = assertCreateFrame('Cooldown')
          local frame2 = assertCreateFrame('Cooldown')
          assertEquals('Cooldown', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                Clear = function()
                  assertEquals('function', type(mt.__index.Clear))
                end,
                GetCooldownDisplayDuration = function()
                  assertEquals('function', type(mt.__index.GetCooldownDisplayDuration))
                end,
                GetCooldownDuration = function()
                  assertEquals('function', type(mt.__index.GetCooldownDuration))
                end,
                GetCooldownTimes = function()
                  assertEquals('function', type(mt.__index.GetCooldownTimes))
                end,
                GetDrawBling = function()
                  assertEquals('function', type(mt.__index.GetDrawBling))
                end,
                GetDrawEdge = function()
                  assertEquals('function', type(mt.__index.GetDrawEdge))
                end,
                GetDrawSwipe = function()
                  assertEquals('function', type(mt.__index.GetDrawSwipe))
                end,
                GetEdgeScale = function()
                  assertEquals('function', type(mt.__index.GetEdgeScale))
                end,
                GetReverse = function()
                  assertEquals('function', type(mt.__index.GetReverse))
                end,
                GetRotation = function()
                  assertEquals('function', type(mt.__index.GetRotation))
                end,
                IsPaused = function()
                  assertEquals('function', type(mt.__index.IsPaused))
                end,
                Pause = function()
                  assertEquals('function', type(mt.__index.Pause))
                end,
                Resume = function()
                  assertEquals('function', type(mt.__index.Resume))
                end,
                SetBlingTexture = function()
                  assertEquals('function', type(mt.__index.SetBlingTexture))
                end,
                SetCooldown = function()
                  assertEquals('function', type(mt.__index.SetCooldown))
                end,
                SetCooldownDuration = function()
                  assertEquals('function', type(mt.__index.SetCooldownDuration))
                end,
                SetCooldownUNIX = function()
                  assertEquals('function', type(mt.__index.SetCooldownUNIX))
                end,
                SetCountdownAbbrevThreshold = function()
                  assertEquals('function', type(mt.__index.SetCountdownAbbrevThreshold))
                end,
                SetCountdownFont = function()
                  assertEquals('function', type(mt.__index.SetCountdownFont))
                end,
                SetDrawBling = function()
                  assertEquals('function', type(mt.__index.SetDrawBling))
                end,
                SetDrawEdge = function()
                  assertEquals('function', type(mt.__index.SetDrawEdge))
                end,
                SetDrawSwipe = function()
                  assertEquals('function', type(mt.__index.SetDrawSwipe))
                end,
                SetEdgeScale = function()
                  assertEquals('function', type(mt.__index.SetEdgeScale))
                end,
                SetEdgeTexture = function()
                  assertEquals('function', type(mt.__index.SetEdgeTexture))
                end,
                SetHideCountdownNumbers = function()
                  assertEquals('function', type(mt.__index.SetHideCountdownNumbers))
                end,
                SetReverse = function()
                  assertEquals('function', type(mt.__index.SetReverse))
                end,
                SetRotation = function()
                  assertEquals('function', type(mt.__index.SetRotation))
                end,
                SetSwipeColor = function()
                  assertEquals('function', type(mt.__index.SetSwipeColor))
                end,
                SetSwipeTexture = function()
                  assertEquals('function', type(mt.__index.SetSwipeTexture))
                end,
                SetUseCircularEdge = function()
                  assertEquals('function', type(mt.__index.SetUseCircularEdge))
                end,
              }
            end,
          }
        end,
        DressUpModel = function()
          local frame = assertCreateFrame('DressUpModel')
          local frame2 = assertCreateFrame('DressUpModel')
          assertEquals('DressUpModel', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                SetAutoDress = function()
                  assertEquals('function', type(mt.__index.SetAutoDress))
                end,
              }
            end,
          }
        end,
        EditBox = function()
          local frame = assertCreateFrame('EditBox')
          local frame2 = assertCreateFrame('EditBox')
          frame:Hide() -- captures input focus otherwise
          frame2:Hide() -- captures input focus otherwise
          assertEquals('EditBox', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                AddHistoryLine = function()
                  assertEquals('function', type(mt.__index.AddHistoryLine))
                end,
                ClearFocus = function()
                  assertEquals('function', type(mt.__index.ClearFocus))
                end,
                ClearHistory = function()
                  assertEquals('function', type(mt.__index.ClearHistory))
                end,
                Disable = function()
                  assertEquals('function', type(mt.__index.Disable))
                end,
                Enable = function()
                  assertEquals('function', type(mt.__index.Enable))
                end,
                GetHistoryLines = function()
                  assertEquals('function', type(mt.__index.GetHistoryLines))
                end,
                GetInputLanguage = function()
                  assertEquals('function', type(mt.__index.GetInputLanguage))
                end,
                GetMaxBytes = function()
                  assertEquals('function', type(mt.__index.GetMaxBytes))
                end,
                GetMaxLetters = function()
                  assertEquals('function', type(mt.__index.GetMaxLetters))
                end,
                GetNumber = function()
                  assertEquals('function', type(mt.__index.GetNumber))
                end,
                GetText = function()
                  assertEquals('function', type(mt.__index.GetText))
                end,
                HasFocus = function()
                  assertEquals('function', type(mt.__index.HasFocus))
                end,
                HighlightText = function()
                  assertEquals('function', type(mt.__index.HighlightText))
                end,
                Insert = function()
                  assertEquals('function', type(mt.__index.Insert))
                end,
                IsAutoFocus = function()
                  assertEquals('function', type(mt.__index.IsAutoFocus))
                end,
                IsCountInvisibleLetters = function()
                  assertEquals('function', type(mt.__index.IsCountInvisibleLetters))
                end,
                IsEnabled = function()
                  assertEquals('function', type(mt.__index.IsEnabled))
                end,
                IsMultiLine = function()
                  assertEquals('function', type(mt.__index.IsMultiLine))
                end,
                IsSecureText = function()
                  assertEquals('function', type(mt.__index.IsSecureText))
                end,
                SetAltArrowKeyMode = function()
                  assertEquals('function', type(mt.__index.SetAltArrowKeyMode))
                end,
                SetAutoFocus = function()
                  assertEquals('function', type(mt.__index.SetAutoFocus))
                end,
                SetCountInvisibleLetters = function()
                  assertEquals('function', type(mt.__index.SetCountInvisibleLetters))
                end,
                SetCursorPosition = function()
                  assertEquals('function', type(mt.__index.SetCursorPosition))
                end,
                SetEnabled = function()
                  assertEquals('function', type(mt.__index.SetEnabled))
                end,
                SetFocus = function()
                  assertEquals('function', type(mt.__index.SetFocus))
                end,
                SetHighlightColor = function()
                  assertEquals('function', type(mt.__index.SetHighlightColor))
                end,
                SetHistoryLines = function()
                  assertEquals('function', type(mt.__index.SetHistoryLines))
                end,
                SetMaxBytes = function()
                  assertEquals('function', type(mt.__index.SetMaxBytes))
                end,
                SetMaxLetters = function()
                  assertEquals('function', type(mt.__index.SetMaxLetters))
                end,
                SetMultiLine = function()
                  assertEquals('function', type(mt.__index.SetMultiLine))
                end,
                SetNumber = function()
                  assertEquals('function', type(mt.__index.SetNumber))
                end,
                SetNumeric = function()
                  assertEquals('function', type(mt.__index.SetNumeric))
                end,
                SetSecureText = function()
                  assertEquals('function', type(mt.__index.SetSecureText))
                end,
                SetSecurityDisablePaste = function()
                  assertEquals('function', type(mt.__index.SetSecurityDisablePaste))
                end,
                SetSecurityDisableSetText = function()
                  assertEquals('function', type(mt.__index.SetSecurityDisableSetText))
                end,
                SetText = function()
                  assertEquals('function', type(mt.__index.SetText))
                end,
                SetTextInsets = function()
                  assertEquals('function', type(mt.__index.SetTextInsets))
                end,
              }
            end,
          }
        end,
        FogOfWarFrame = function()
          local frame = assertCreateFrame('FogOfWarFrame')
          local frame2 = assertCreateFrame('FogOfWarFrame')
          assertEquals('FogOfWarFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
        end,
        Font = function()
          assertCreateFrameFails('Font')
        end,
        FontInstance = function()
          assertCreateFrameFails('FontInstance')
        end,
        FontString = function()
          assertCreateFrameFails('FontString')
        end,
        Frame = function()
          local frame = assertCreateFrame('Frame')
          local frame2 = assertCreateFrame('Frame')
          assertEquals('Frame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                CreateFontString = function()
                  assertEquals('function', type(mt.__index.CreateFontString))
                end,
                CreateLine = function()
                  assertEquals('function', type(mt.__index.CreateLine))
                end,
                CreateMaskTexture = function()
                  assertEquals('function', type(mt.__index.CreateMaskTexture))
                end,
                CreateTexture = function()
                  assertEquals('function', type(mt.__index.CreateTexture))
                end,
                DesaturateHierarchy = function()
                  assertEquals('function', type(mt.__index.DesaturateHierarchy))
                end,
                DisableDrawLayer = function()
                  assertEquals('function', type(mt.__index.DisableDrawLayer))
                end,
                EnableKeyboard = function()
                  assertEquals('function', type(mt.__index.EnableKeyboard))
                end,
                EnableMouse = function()
                  assertEquals('function', type(mt.__index.EnableMouse))
                end,
                EnableMouseWheel = function()
                  assertEquals('function', type(mt.__index.EnableMouseWheel))
                end,
                GetAttribute = function()
                  assertEquals('function', type(mt.__index.GetAttribute))
                end,
                GetChildren = function()
                  assertEquals('function', type(mt.__index.GetChildren))
                end,
                GetFrameLevel = function()
                  assertEquals('function', type(mt.__index.GetFrameLevel))
                end,
                GetFrameStrata = function()
                  assertEquals('function', type(mt.__index.GetFrameStrata))
                end,
                GetHyperlinksEnabled = function()
                  assertEquals('function', type(mt.__index.GetHyperlinksEnabled))
                end,
                GetID = function()
                  assertEquals('function', type(mt.__index.GetID))
                end,
                GetMaxResize = function()
                  assertEquals('function', type(mt.__index.GetMaxResize))
                end,
                GetMinResize = function()
                  assertEquals('function', type(mt.__index.GetMinResize))
                end,
                GetNumChildren = function()
                  assertEquals('function', type(mt.__index.GetNumChildren))
                end,
                GetNumRegions = function()
                  assertEquals('function', type(mt.__index.GetNumRegions))
                end,
                GetPropagateKeyboardInput = function()
                  assertEquals('function', type(mt.__index.GetPropagateKeyboardInput))
                end,
                GetRegions = function()
                  assertEquals('function', type(mt.__index.GetRegions))
                end,
                IgnoreDepth = function()
                  assertEquals('function', type(mt.__index.IgnoreDepth))
                end,
                IsClampedToScreen = function()
                  assertEquals('function', type(mt.__index.IsClampedToScreen))
                end,
                IsEventRegistered = function()
                  assertEquals('function', type(mt.__index.IsEventRegistered))
                end,
                IsMouseClickEnabled = function()
                  assertEquals('function', type(mt.__index.IsMouseClickEnabled))
                end,
                IsMouseEnabled = function()
                  assertEquals('function', type(mt.__index.IsMouseEnabled))
                end,
                IsMouseMotionEnabled = function()
                  assertEquals('function', type(mt.__index.IsMouseMotionEnabled))
                end,
                IsMouseWheelEnabled = function()
                  assertEquals('function', type(mt.__index.IsMouseWheelEnabled))
                end,
                IsMovable = function()
                  assertEquals('function', type(mt.__index.IsMovable))
                end,
                IsResizable = function()
                  assertEquals('function', type(mt.__index.IsResizable))
                end,
                IsToplevel = function()
                  assertEquals('function', type(mt.__index.IsToplevel))
                end,
                IsUserPlaced = function()
                  assertEquals('function', type(mt.__index.IsUserPlaced))
                end,
                Raise = function()
                  assertEquals('function', type(mt.__index.Raise))
                end,
                RegisterAllEvents = function()
                  assertEquals('function', type(mt.__index.RegisterAllEvents))
                end,
                RegisterEvent = function()
                  assertEquals('function', type(mt.__index.RegisterEvent))
                end,
                RegisterForDrag = function()
                  assertEquals('function', type(mt.__index.RegisterForDrag))
                end,
                RegisterUnitEvent = function()
                  assertEquals('function', type(mt.__index.RegisterUnitEvent))
                end,
                SetAttribute = function()
                  assertEquals('function', type(mt.__index.SetAttribute))
                end,
                SetAttributeNoHandler = function()
                  assertEquals('function', type(mt.__index.SetAttributeNoHandler))
                end,
                SetClampRectInsets = function()
                  assertEquals('function', type(mt.__index.SetClampRectInsets))
                end,
                SetClampedToScreen = function()
                  assertEquals('function', type(mt.__index.SetClampedToScreen))
                end,
                SetClipsChildren = function()
                  assertEquals('function', type(mt.__index.SetClipsChildren))
                end,
                SetDepth = function()
                  assertEquals('function', type(mt.__index.SetDepth))
                end,
                SetDontSavePosition = function()
                  assertEquals('function', type(mt.__index.SetDontSavePosition))
                end,
                SetFixedFrameLevel = function()
                  assertEquals('function', type(mt.__index.SetFixedFrameLevel))
                end,
                SetFixedFrameStrata = function()
                  assertEquals('function', type(mt.__index.SetFixedFrameStrata))
                end,
                SetFrameLevel = function()
                  assertEquals('function', type(mt.__index.SetFrameLevel))
                end,
                SetFrameStrata = function()
                  assertEquals('function', type(mt.__index.SetFrameStrata))
                end,
                SetHitRectInsets = function()
                  assertEquals('function', type(mt.__index.SetHitRectInsets))
                end,
                SetHyperlinksEnabled = function()
                  assertEquals('function', type(mt.__index.SetHyperlinksEnabled))
                end,
                SetID = function()
                  assertEquals('function', type(mt.__index.SetID))
                end,
                SetMaxResize = function()
                  assertEquals('function', type(mt.__index.SetMaxResize))
                end,
                SetMinResize = function()
                  assertEquals('function', type(mt.__index.SetMinResize))
                end,
                SetMouseClickEnabled = function()
                  assertEquals('function', type(mt.__index.SetMouseClickEnabled))
                end,
                SetMouseMotionEnabled = function()
                  assertEquals('function', type(mt.__index.SetMouseMotionEnabled))
                end,
                SetMovable = function()
                  assertEquals('function', type(mt.__index.SetMovable))
                end,
                SetPropagateKeyboardInput = function()
                  assertEquals('function', type(mt.__index.SetPropagateKeyboardInput))
                end,
                SetResizable = function()
                  assertEquals('function', type(mt.__index.SetResizable))
                end,
                SetToplevel = function()
                  assertEquals('function', type(mt.__index.SetToplevel))
                end,
                SetUserPlaced = function()
                  assertEquals('function', type(mt.__index.SetUserPlaced))
                end,
                StartMoving = function()
                  assertEquals('function', type(mt.__index.StartMoving))
                end,
                StopMovingOrSizing = function()
                  assertEquals('function', type(mt.__index.StopMovingOrSizing))
                end,
                UnregisterAllEvents = function()
                  assertEquals('function', type(mt.__index.UnregisterAllEvents))
                end,
                UnregisterEvent = function()
                  assertEquals('function', type(mt.__index.UnregisterEvent))
                end,
              }
            end,
          }
        end,
        GameTooltip = function()
          local frame = assertCreateFrame('GameTooltip')
          local frame2 = assertCreateFrame('GameTooltip')
          assertEquals('GameTooltip', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                AddAtlas = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.AddAtlas))
                    return
                  end
                  assertEquals('function', type(mt.__index.AddAtlas))
                end,
                AddDoubleLine = function()
                  assertEquals('function', type(mt.__index.AddDoubleLine))
                end,
                AddFontStrings = function()
                  assertEquals('function', type(mt.__index.AddFontStrings))
                end,
                AddLine = function()
                  assertEquals('function', type(mt.__index.AddLine))
                end,
                AddSpellByID = function()
                  assertEquals('function', type(mt.__index.AddSpellByID))
                end,
                AddTexture = function()
                  assertEquals('function', type(mt.__index.AddTexture))
                end,
                AdvanceSecondaryCompareItem = function()
                  assertEquals('function', type(mt.__index.AdvanceSecondaryCompareItem))
                end,
                AppendText = function()
                  assertEquals('function', type(mt.__index.AppendText))
                end,
                ClearLines = function()
                  assertEquals('function', type(mt.__index.ClearLines))
                end,
                CopyTooltip = function()
                  assertEquals('function', type(mt.__index.CopyTooltip))
                end,
                FadeOut = function()
                  assertEquals('function', type(mt.__index.FadeOut))
                end,
                GetAnchorType = function()
                  assertEquals('function', type(mt.__index.GetAnchorType))
                end,
                GetAzeritePowerID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.GetAzeritePowerID))
                    return
                  end
                  assertEquals('function', type(mt.__index.GetAzeritePowerID))
                end,
                GetCustomLineSpacing = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.GetCustomLineSpacing))
                    return
                  end
                  assertEquals('function', type(mt.__index.GetCustomLineSpacing))
                end,
                GetItem = function()
                  assertEquals('function', type(mt.__index.GetItem))
                end,
                GetMinimumWidth = function()
                  assertEquals('function', type(mt.__index.GetMinimumWidth))
                end,
                GetOwner = function()
                  assertEquals('function', type(mt.__index.GetOwner))
                end,
                GetPadding = function()
                  assertEquals('function', type(mt.__index.GetPadding))
                end,
                GetSpell = function()
                  assertEquals('function', type(mt.__index.GetSpell))
                end,
                GetUnit = function()
                  assertEquals('function', type(mt.__index.GetUnit))
                end,
                IsEquippedItem = function()
                  assertEquals('function', type(mt.__index.IsEquippedItem))
                end,
                IsOwned = function()
                  assertEquals('function', type(mt.__index.IsOwned))
                end,
                IsUnit = function()
                  assertEquals('function', type(mt.__index.IsUnit))
                end,
                NumLines = function()
                  assertEquals('function', type(mt.__index.NumLines))
                end,
                ResetSecondaryCompareItem = function()
                  assertEquals('function', type(mt.__index.ResetSecondaryCompareItem))
                end,
                SetAchievementByID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAchievementByID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAchievementByID))
                end,
                SetAction = function()
                  assertEquals('function', type(mt.__index.SetAction))
                end,
                SetAllowShowWithNoLines = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAllowShowWithNoLines))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAllowShowWithNoLines))
                end,
                SetAnchorType = function()
                  assertEquals('function', type(mt.__index.SetAnchorType))
                end,
                SetArtifactItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetArtifactItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetArtifactItem))
                end,
                SetArtifactPowerByID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetArtifactPowerByID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetArtifactPowerByID))
                end,
                SetAuctionItem = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAuctionItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAuctionItem))
                end,
                SetAuctionSellItem = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAuctionSellItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAuctionSellItem))
                end,
                SetAzeriteEssence = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAzeriteEssence))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAzeriteEssence))
                end,
                SetAzeriteEssenceSlot = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAzeriteEssenceSlot))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAzeriteEssenceSlot))
                end,
                SetAzeritePower = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetAzeritePower))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetAzeritePower))
                end,
                SetBackpackToken = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetBackpackToken))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetBackpackToken))
                end,
                SetBagItem = function()
                  assertEquals('function', type(mt.__index.SetBagItem))
                end,
                SetBagItemChild = function()
                  assertEquals('function', type(mt.__index.SetBagItemChild))
                end,
                SetBuybackItem = function()
                  assertEquals('function', type(mt.__index.SetBuybackItem))
                end,
                SetCompanionPet = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCompanionPet))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCompanionPet))
                end,
                SetCompareAzeritePower = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCompareAzeritePower))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCompareAzeritePower))
                end,
                SetCompareItem = function()
                  assertEquals('function', type(mt.__index.SetCompareItem))
                end,
                SetConduit = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetConduit))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetConduit))
                end,
                SetCraftItem = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCraftItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCraftItem))
                end,
                SetCraftSpell = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCraftSpell))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCraftSpell))
                end,
                SetCurrencyByID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCurrencyByID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCurrencyByID))
                end,
                SetCurrencyToken = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCurrencyToken))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCurrencyToken))
                end,
                SetCurrencyTokenByID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCurrencyTokenByID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCurrencyTokenByID))
                end,
                SetCustomLineSpacing = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetCustomLineSpacing))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetCustomLineSpacing))
                end,
                SetEnhancedConduit = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetEnhancedConduit))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetEnhancedConduit))
                end,
                SetEquipmentSet = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetEquipmentSet))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetEquipmentSet))
                end,
                SetExistingSocketGem = function()
                  assertEquals('function', type(mt.__index.SetExistingSocketGem))
                end,
                SetFrameStack = function()
                  assertEquals('function', type(mt.__index.SetFrameStack))
                end,
                SetGuildBankItem = function()
                  assertEquals('function', type(mt.__index.SetGuildBankItem))
                end,
                SetHeirloomByItemID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetHeirloomByItemID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetHeirloomByItemID))
                end,
                SetHyperlink = function()
                  assertEquals('function', type(mt.__index.SetHyperlink))
                end,
                SetInboxItem = function()
                  assertEquals('function', type(mt.__index.SetInboxItem))
                end,
                SetInstanceLockEncountersComplete = function()
                  assertEquals('function', type(mt.__index.SetInstanceLockEncountersComplete))
                end,
                SetInventoryItem = function()
                  assertEquals('function', type(mt.__index.SetInventoryItem))
                end,
                SetInventoryItemByID = function()
                  assertEquals('function', type(mt.__index.SetInventoryItemByID))
                end,
                SetItemByID = function()
                  assertEquals('function', type(mt.__index.SetItemByID))
                end,
                SetItemKey = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetItemKey))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetItemKey))
                end,
                SetLFGDungeonReward = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetLFGDungeonReward))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetLFGDungeonReward))
                end,
                SetLFGDungeonShortageReward = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetLFGDungeonShortageReward))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetLFGDungeonShortageReward))
                end,
                SetLootCurrency = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetLootCurrency))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetLootCurrency))
                end,
                SetLootItem = function()
                  assertEquals('function', type(mt.__index.SetLootItem))
                end,
                SetLootRollItem = function()
                  assertEquals('function', type(mt.__index.SetLootRollItem))
                end,
                SetMerchantCostItem = function()
                  assertEquals('function', type(mt.__index.SetMerchantCostItem))
                end,
                SetMerchantItem = function()
                  assertEquals('function', type(mt.__index.SetMerchantItem))
                end,
                SetMinimumWidth = function()
                  assertEquals('function', type(mt.__index.SetMinimumWidth))
                end,
                SetMountBySpellID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetMountBySpellID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetMountBySpellID))
                end,
                SetOwnedItemByID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetOwnedItemByID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetOwnedItemByID))
                end,
                SetOwner = function()
                  assertEquals('function', type(mt.__index.SetOwner))
                end,
                SetPadding = function()
                  assertEquals('function', type(mt.__index.SetPadding))
                end,
                SetPetAction = function()
                  assertEquals('function', type(mt.__index.SetPetAction))
                end,
                SetPossession = function()
                  assertEquals('function', type(mt.__index.SetPossession))
                end,
                SetPvpBrawl = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetPvpBrawl))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetPvpBrawl))
                end,
                SetPvpTalent = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetPvpTalent))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetPvpTalent))
                end,
                SetQuestCurrency = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetQuestCurrency))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetQuestCurrency))
                end,
                SetQuestItem = function()
                  assertEquals('function', type(mt.__index.SetQuestItem))
                end,
                SetQuestLogCurrency = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetQuestLogCurrency))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetQuestLogCurrency))
                end,
                SetQuestLogItem = function()
                  assertEquals('function', type(mt.__index.SetQuestLogItem))
                end,
                SetQuestLogRewardSpell = function()
                  assertEquals('function', type(mt.__index.SetQuestLogRewardSpell))
                end,
                SetQuestLogSpecialItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetQuestLogSpecialItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetQuestLogSpecialItem))
                end,
                SetQuestPartyProgress = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetQuestPartyProgress))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetQuestPartyProgress))
                end,
                SetQuestRewardSpell = function()
                  assertEquals('function', type(mt.__index.SetQuestRewardSpell))
                end,
                SetRecipeRankInfo = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetRecipeRankInfo))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetRecipeRankInfo))
                end,
                SetRecipeReagentItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetRecipeReagentItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetRecipeReagentItem))
                end,
                SetRecipeResultItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetRecipeResultItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetRecipeResultItem))
                end,
                SetRuneforgeResultItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetRuneforgeResultItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetRuneforgeResultItem))
                end,
                SetSendMailItem = function()
                  assertEquals('function', type(mt.__index.SetSendMailItem))
                end,
                SetShapeshift = function()
                  assertEquals('function', type(mt.__index.SetShapeshift))
                end,
                SetShrinkToFitWrapped = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetShrinkToFitWrapped))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetShrinkToFitWrapped))
                end,
                SetSocketGem = function()
                  assertEquals('function', type(mt.__index.SetSocketGem))
                end,
                SetSocketedItem = function()
                  assertEquals('function', type(mt.__index.SetSocketedItem))
                end,
                SetSocketedRelic = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetSocketedRelic))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetSocketedRelic))
                end,
                SetSpellBookItem = function()
                  assertEquals('function', type(mt.__index.SetSpellBookItem))
                end,
                SetSpellByID = function()
                  assertEquals('function', type(mt.__index.SetSpellByID))
                end,
                SetTalent = function()
                  assertEquals('function', type(mt.__index.SetTalent))
                end,
                SetText = function()
                  assertEquals('function', type(mt.__index.SetText))
                end,
                SetTotem = function()
                  assertEquals('function', type(mt.__index.SetTotem))
                end,
                SetToyByItemID = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetToyByItemID))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetToyByItemID))
                end,
                SetTrackingSpell = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetTrackingSpell))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetTrackingSpell))
                end,
                SetTradePlayerItem = function()
                  assertEquals('function', type(mt.__index.SetTradePlayerItem))
                end,
                SetTradeSkillItem = function()
                  if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetTradeSkillItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetTradeSkillItem))
                end,
                SetTradeTargetItem = function()
                  assertEquals('function', type(mt.__index.SetTradeTargetItem))
                end,
                SetTrainerService = function()
                  assertEquals('function', type(mt.__index.SetTrainerService))
                end,
                SetTransmogrifyItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetTransmogrifyItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetTransmogrifyItem))
                end,
                SetUnit = function()
                  assertEquals('function', type(mt.__index.SetUnit))
                end,
                SetUnitAura = function()
                  assertEquals('function', type(mt.__index.SetUnitAura))
                end,
                SetUnitBuff = function()
                  assertEquals('function', type(mt.__index.SetUnitBuff))
                end,
                SetUnitDebuff = function()
                  assertEquals('function', type(mt.__index.SetUnitDebuff))
                end,
                SetUpgradeItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetUpgradeItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetUpgradeItem))
                end,
                SetVoidDepositItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetVoidDepositItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetVoidDepositItem))
                end,
                SetVoidItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetVoidItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetVoidItem))
                end,
                SetVoidWithdrawalItem = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetVoidWithdrawalItem))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetVoidWithdrawalItem))
                end,
                SetWeeklyReward = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetWeeklyReward))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetWeeklyReward))
                end,
              }
            end,
          }
        end,
        LayeredRegion = function()
          assertCreateFrameFails('LayeredRegion')
        end,
        Line = function()
          assertCreateFrameFails('Line')
        end,
        MaskTexture = function()
          assertCreateFrameFails('MaskTexture')
        end,
        MessageFrame = function()
          local frame = assertCreateFrame('MessageFrame')
          local frame2 = assertCreateFrame('MessageFrame')
          assertEquals('MessageFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                AddMessage = function()
                  assertEquals('function', type(mt.__index.AddMessage))
                end,
                Clear = function()
                  assertEquals('function', type(mt.__index.Clear))
                end,
              }
            end,
          }
        end,
        Model = function()
          local frame = assertCreateFrame('Model')
          local frame2 = assertCreateFrame('Model')
          assertEquals('Model', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                ClearModel = function()
                  assertEquals('function', type(mt.__index.ClearModel))
                end,
                GetModelScale = function()
                  assertEquals('function', type(mt.__index.GetModelScale))
                end,
                SetFacing = function()
                  assertEquals('function', type(mt.__index.SetFacing))
                end,
                SetLight = function()
                  assertEquals('function', type(mt.__index.SetLight))
                end,
                SetModel = function()
                  assertEquals('function', type(mt.__index.SetModel))
                end,
                SetModelScale = function()
                  assertEquals('function', type(mt.__index.SetModelScale))
                end,
                SetPosition = function()
                  assertEquals('function', type(mt.__index.SetPosition))
                end,
                TransformCameraSpaceToModelSpace = function()
                  assertEquals('function', type(mt.__index.TransformCameraSpaceToModelSpace))
                end,
              }
            end,
          }
        end,
        ModelScene = function()
          local frame = assertCreateFrame('ModelScene')
          local frame2 = assertCreateFrame('ModelScene')
          assertEquals('ModelScene', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                ClearFog = function()
                  assertEquals('function', type(mt.__index.ClearFog))
                end,
                CreateActor = function()
                  assertEquals('function', type(mt.__index.CreateActor))
                end,
                GetActorAtIndex = function()
                  assertEquals('function', type(mt.__index.GetActorAtIndex))
                end,
                GetCameraFarClip = function()
                  assertEquals('function', type(mt.__index.GetCameraFarClip))
                end,
                GetCameraFieldOfView = function()
                  assertEquals('function', type(mt.__index.GetCameraFieldOfView))
                end,
                GetCameraForward = function()
                  assertEquals('function', type(mt.__index.GetCameraForward))
                end,
                GetCameraNearClip = function()
                  assertEquals('function', type(mt.__index.GetCameraNearClip))
                end,
                GetCameraPosition = function()
                  assertEquals('function', type(mt.__index.GetCameraPosition))
                end,
                GetCameraRight = function()
                  assertEquals('function', type(mt.__index.GetCameraRight))
                end,
                GetCameraUp = function()
                  assertEquals('function', type(mt.__index.GetCameraUp))
                end,
                GetDrawLayer = function()
                  assertEquals('function', type(mt.__index.GetDrawLayer))
                end,
                GetFogColor = function()
                  assertEquals('function', type(mt.__index.GetFogColor))
                end,
                GetFogFar = function()
                  assertEquals('function', type(mt.__index.GetFogFar))
                end,
                GetFogNear = function()
                  assertEquals('function', type(mt.__index.GetFogNear))
                end,
                GetLightAmbientColor = function()
                  assertEquals('function', type(mt.__index.GetLightAmbientColor))
                end,
                GetLightDiffuseColor = function()
                  assertEquals('function', type(mt.__index.GetLightDiffuseColor))
                end,
                GetLightDirection = function()
                  assertEquals('function', type(mt.__index.GetLightDirection))
                end,
                GetLightPosition = function()
                  assertEquals('function', type(mt.__index.GetLightPosition))
                end,
                GetLightType = function()
                  assertEquals('function', type(mt.__index.GetLightType))
                end,
                GetNumActors = function()
                  assertEquals('function', type(mt.__index.GetNumActors))
                end,
                GetViewInsets = function()
                  assertEquals('function', type(mt.__index.GetViewInsets))
                end,
                GetViewTranslation = function()
                  assertEquals('function', type(mt.__index.GetViewTranslation))
                end,
                IsLightVisible = function()
                  assertEquals('function', type(mt.__index.IsLightVisible))
                end,
                Project3DPointTo2D = function()
                  assertEquals('function', type(mt.__index.Project3DPointTo2D))
                end,
                SetCameraFarClip = function()
                  assertEquals('function', type(mt.__index.SetCameraFarClip))
                end,
                SetCameraFieldOfView = function()
                  assertEquals('function', type(mt.__index.SetCameraFieldOfView))
                end,
                SetCameraNearClip = function()
                  assertEquals('function', type(mt.__index.SetCameraNearClip))
                end,
                SetCameraOrientationByAxisVectors = function()
                  assertEquals('function', type(mt.__index.SetCameraOrientationByAxisVectors))
                end,
                SetCameraOrientationByYawPitchRoll = function()
                  assertEquals('function', type(mt.__index.SetCameraOrientationByYawPitchRoll))
                end,
                SetCameraPosition = function()
                  assertEquals('function', type(mt.__index.SetCameraPosition))
                end,
                SetDesaturation = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetDesaturation))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetDesaturation))
                end,
                SetDrawLayer = function()
                  assertEquals('function', type(mt.__index.SetDrawLayer))
                end,
                SetFogColor = function()
                  assertEquals('function', type(mt.__index.SetFogColor))
                end,
                SetFogFar = function()
                  assertEquals('function', type(mt.__index.SetFogFar))
                end,
                SetFogNear = function()
                  assertEquals('function', type(mt.__index.SetFogNear))
                end,
                SetLightAmbientColor = function()
                  assertEquals('function', type(mt.__index.SetLightAmbientColor))
                end,
                SetLightDiffuseColor = function()
                  assertEquals('function', type(mt.__index.SetLightDiffuseColor))
                end,
                SetLightDirection = function()
                  assertEquals('function', type(mt.__index.SetLightDirection))
                end,
                SetLightPosition = function()
                  assertEquals('function', type(mt.__index.SetLightPosition))
                end,
                SetLightType = function()
                  assertEquals('function', type(mt.__index.SetLightType))
                end,
                SetLightVisible = function()
                  assertEquals('function', type(mt.__index.SetLightVisible))
                end,
                SetPaused = function()
                  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                    assertEquals('nil', type(mt.__index.SetPaused))
                    return
                  end
                  assertEquals('function', type(mt.__index.SetPaused))
                end,
                SetViewInsets = function()
                  assertEquals('function', type(mt.__index.SetViewInsets))
                end,
                SetViewTranslation = function()
                  assertEquals('function', type(mt.__index.SetViewTranslation))
                end,
                TakeActor = function()
                  assertEquals('function', type(mt.__index.TakeActor))
                end,
              }
            end,
          }
        end,
        MovieFrame = function()
          local frame = assertCreateFrame('MovieFrame')
          local frame2 = assertCreateFrame('MovieFrame')
          assertEquals('MovieFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                EnableSubtitles = function()
                  assertEquals('function', type(mt.__index.EnableSubtitles))
                end,
                StartMovie = function()
                  assertEquals('function', type(mt.__index.StartMovie))
                end,
                StopMovie = function()
                  assertEquals('function', type(mt.__index.StopMovie))
                end,
              }
            end,
          }
        end,
        OffScreenFrame = function()
          local frame = assertCreateFrame('OffScreenFrame')
          local frame2 = assertCreateFrame('OffScreenFrame')
          assertEquals('OffScreenFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
          }
        end,
        POIFrame = function()
          assertCreateFrameFails('POIFrame')
        end,
        ParentedObject = function()
          assertCreateFrameFails('ParentedObject')
        end,
        Path = function()
          assertCreateFrameFails('Path')
        end,
        PlayerModel = function()
          local frame = assertCreateFrame('PlayerModel')
          local frame2 = assertCreateFrame('PlayerModel')
          assertEquals('PlayerModel', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                FreezeAnimation = function()
                  assertEquals('function', type(mt.__index.FreezeAnimation))
                end,
                GetDisplayInfo = function()
                  assertEquals('function', type(mt.__index.GetDisplayInfo))
                end,
                RefreshCamera = function()
                  assertEquals('function', type(mt.__index.RefreshCamera))
                end,
                RefreshUnit = function()
                  assertEquals('function', type(mt.__index.RefreshUnit))
                end,
                SetAnimation = function()
                  assertEquals('function', type(mt.__index.SetAnimation))
                end,
                SetCamDistanceScale = function()
                  assertEquals('function', type(mt.__index.SetCamDistanceScale))
                end,
                SetDisplayInfo = function()
                  assertEquals('function', type(mt.__index.SetDisplayInfo))
                end,
                SetDoBlend = function()
                  assertEquals('function', type(mt.__index.SetDoBlend))
                end,
                SetKeepModelOnHide = function()
                  assertEquals('function', type(mt.__index.SetKeepModelOnHide))
                end,
                SetPortraitZoom = function()
                  assertEquals('function', type(mt.__index.SetPortraitZoom))
                end,
                SetRotation = function()
                  assertEquals('function', type(mt.__index.SetRotation))
                end,
                SetUnit = function()
                  assertEquals('function', type(mt.__index.SetUnit))
                end,
              }
            end,
          }
        end,
        QuestPOIFrame = function()
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertCreateFrameFails('QuestPOIFrame')
            return
          end
          local frame = assertCreateFrame('QuestPOIFrame')
          local frame2 = assertCreateFrame('QuestPOIFrame')
          assertEquals('QuestPOIFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
          }
        end,
        Region = function()
          assertCreateFrameFails('Region')
        end,
        Rotation = function()
          assertCreateFrameFails('Rotation')
        end,
        Scale = function()
          assertCreateFrameFails('Scale')
        end,
        ScenarioPOIFrame = function()
          if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
            assertCreateFrameFails('ScenarioPOIFrame')
            return
          end
          local frame = assertCreateFrame('ScenarioPOIFrame')
          local frame2 = assertCreateFrame('ScenarioPOIFrame')
          assertEquals('ScenarioPOIFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
          }
        end,
        ScriptObject = function()
          assertCreateFrameFails('ScriptObject')
        end,
        ScrollFrame = function()
          local frame = assertCreateFrame('ScrollFrame')
          local frame2 = assertCreateFrame('ScrollFrame')
          assertEquals('ScrollFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetHorizontalScroll = function()
                  assertEquals('function', type(mt.__index.GetHorizontalScroll))
                end,
                GetHorizontalScrollRange = function()
                  assertEquals('function', type(mt.__index.GetHorizontalScrollRange))
                end,
                GetScrollChild = function()
                  assertEquals('function', type(mt.__index.GetScrollChild))
                end,
                GetVerticalScroll = function()
                  assertEquals('function', type(mt.__index.GetVerticalScroll))
                end,
                GetVerticalScrollRange = function()
                  assertEquals('function', type(mt.__index.GetVerticalScrollRange))
                end,
                SetHorizontalScroll = function()
                  assertEquals('function', type(mt.__index.SetHorizontalScroll))
                end,
                SetScrollChild = function()
                  assertEquals('function', type(mt.__index.SetScrollChild))
                end,
                SetVerticalScroll = function()
                  assertEquals('function', type(mt.__index.SetVerticalScroll))
                end,
                UpdateScrollChildRect = function()
                  assertEquals('function', type(mt.__index.UpdateScrollChildRect))
                end,
              }
            end,
          }
        end,
        SimpleHTML = function()
          local frame = assertCreateFrame('SimpleHTML')
          local frame2 = assertCreateFrame('SimpleHTML')
          assertEquals('SimpleHTML', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetContentHeight = function()
                  assertEquals('function', type(mt.__index.GetContentHeight))
                end,
                SetText = function()
                  assertEquals('function', type(mt.__index.SetText))
                end,
              }
            end,
          }
        end,
        Slider = function()
          local frame = assertCreateFrame('Slider')
          local frame2 = assertCreateFrame('Slider')
          assertEquals('Slider', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                Disable = function()
                  assertEquals('function', type(mt.__index.Disable))
                end,
                Enable = function()
                  assertEquals('function', type(mt.__index.Enable))
                end,
                GetMinMaxValues = function()
                  assertEquals('function', type(mt.__index.GetMinMaxValues))
                end,
                GetObeyStepOnDrag = function()
                  assertEquals('function', type(mt.__index.GetObeyStepOnDrag))
                end,
                GetOrientation = function()
                  assertEquals('function', type(mt.__index.GetOrientation))
                end,
                GetStepsPerPage = function()
                  assertEquals('function', type(mt.__index.GetStepsPerPage))
                end,
                GetThumbTexture = function()
                  assertEquals('function', type(mt.__index.GetThumbTexture))
                end,
                GetValue = function()
                  assertEquals('function', type(mt.__index.GetValue))
                end,
                GetValueStep = function()
                  assertEquals('function', type(mt.__index.GetValueStep))
                end,
                IsDraggingThumb = function()
                  assertEquals('function', type(mt.__index.IsDraggingThumb))
                end,
                IsEnabled = function()
                  assertEquals('function', type(mt.__index.IsEnabled))
                end,
                SetEnabled = function()
                  assertEquals('function', type(mt.__index.SetEnabled))
                end,
                SetMinMaxValues = function()
                  assertEquals('function', type(mt.__index.SetMinMaxValues))
                end,
                SetObeyStepOnDrag = function()
                  assertEquals('function', type(mt.__index.SetObeyStepOnDrag))
                end,
                SetOrientation = function()
                  assertEquals('function', type(mt.__index.SetOrientation))
                end,
                SetStepsPerPage = function()
                  assertEquals('function', type(mt.__index.SetStepsPerPage))
                end,
                SetThumbTexture = function()
                  assertEquals('function', type(mt.__index.SetThumbTexture))
                end,
                SetValue = function()
                  assertEquals('function', type(mt.__index.SetValue))
                end,
                SetValueStep = function()
                  assertEquals('function', type(mt.__index.SetValueStep))
                end,
              }
            end,
          }
        end,
        StatusBar = function()
          local frame = assertCreateFrame('StatusBar')
          local frame2 = assertCreateFrame('StatusBar')
          assertEquals('StatusBar', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetFillStyle = function()
                  assertEquals('function', type(mt.__index.GetFillStyle))
                end,
                GetMinMaxValues = function()
                  assertEquals('function', type(mt.__index.GetMinMaxValues))
                end,
                GetOrientation = function()
                  assertEquals('function', type(mt.__index.GetOrientation))
                end,
                GetReverseFill = function()
                  assertEquals('function', type(mt.__index.GetReverseFill))
                end,
                GetRotatesTexture = function()
                  assertEquals('function', type(mt.__index.GetRotatesTexture))
                end,
                GetStatusBarAtlas = function()
                  assertEquals('function', type(mt.__index.GetStatusBarAtlas))
                end,
                GetStatusBarColor = function()
                  assertEquals('function', type(mt.__index.GetStatusBarColor))
                end,
                GetStatusBarTexture = function()
                  assertEquals('function', type(mt.__index.GetStatusBarTexture))
                end,
                GetValue = function()
                  assertEquals('function', type(mt.__index.GetValue))
                end,
                SetFillStyle = function()
                  assertEquals('function', type(mt.__index.SetFillStyle))
                end,
                SetMinMaxValues = function()
                  assertEquals('function', type(mt.__index.SetMinMaxValues))
                end,
                SetOrientation = function()
                  assertEquals('function', type(mt.__index.SetOrientation))
                end,
                SetReverseFill = function()
                  assertEquals('function', type(mt.__index.SetReverseFill))
                end,
                SetRotatesTexture = function()
                  assertEquals('function', type(mt.__index.SetRotatesTexture))
                end,
                SetStatusBarAtlas = function()
                  assertEquals('function', type(mt.__index.SetStatusBarAtlas))
                end,
                SetStatusBarColor = function()
                  assertEquals('function', type(mt.__index.SetStatusBarColor))
                end,
                SetStatusBarTexture = function()
                  assertEquals('function', type(mt.__index.SetStatusBarTexture))
                end,
                SetValue = function()
                  assertEquals('function', type(mt.__index.SetValue))
                end,
              }
            end,
          }
        end,
        TabardModel = function()
          local frame = assertCreateFrame('TabardModel')
          local frame2 = assertCreateFrame('TabardModel')
          assertEquals('TabardModel', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                GetLowerEmblemTexture = function()
                  assertEquals('function', type(mt.__index.GetLowerEmblemTexture))
                end,
                GetUpperEmblemTexture = function()
                  assertEquals('function', type(mt.__index.GetUpperEmblemTexture))
                end,
                InitializeTabardColors = function()
                  assertEquals('function', type(mt.__index.InitializeTabardColors))
                end,
              }
            end,
          }
        end,
        Texture = function()
          assertCreateFrameFails('Texture')
        end,
        TextureCoordTranslation = function()
          assertCreateFrameFails('TextureCoordTranslation')
        end,
        Translation = function()
          assertCreateFrameFails('Translation')
        end,
        UIObject = function()
          assertCreateFrameFails('UIObject')
        end,
        UnitPositionFrame = function()
          local frame = assertCreateFrame('UnitPositionFrame')
          local frame2 = assertCreateFrame('UnitPositionFrame')
          assertEquals('UnitPositionFrame', GetObjectType(frame))
          local mt = getmetatable(frame)
          assert(mt == getmetatable(frame2))
          assert(mt ~= nil)
          return {
            contents = function()
              local udk, udv = next(frame)
              assertEquals(udk, 0)
              assertEquals('userdata', type(udv))
              assert(getmetatable(udv) == nil)
              assert(next(frame, udk) == nil)
            end,
            methods = function()
              return {
                AddUnit = function()
                  assertEquals('function', type(mt.__index.AddUnit))
                end,
                ClearUnits = function()
                  assertEquals('function', type(mt.__index.ClearUnits))
                end,
                FinalizeUnits = function()
                  assertEquals('function', type(mt.__index.FinalizeUnits))
                end,
                GetMouseOverUnits = function()
                  assertEquals('function', type(mt.__index.GetMouseOverUnits))
                end,
                SetPlayerPingScale = function()
                  assertEquals('function', type(mt.__index.SetPlayerPingScale))
                end,
                SetPlayerPingTexture = function()
                  assertEquals('function', type(mt.__index.SetPlayerPingTexture))
                end,
                SetUiMapID = function()
                  assertEquals('function', type(mt.__index.SetUiMapID))
                end,
                StartPlayerPing = function()
                  assertEquals('function', type(mt.__index.StartPlayerPing))
                end,
                StopPlayerPing = function()
                  assertEquals('function', type(mt.__index.StopPlayerPing))
                end,
              }
            end,
          }
        end,
      }
    end,
  }
end)
