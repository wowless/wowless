local bitlib = require('bit')
local util = require('wowless.util')
local Mixin = util.mixin

local UNIMPLEMENTED = function() end
local STUB_NUMBER = function() return 1 end

local function toTexture(parent, tex)
  if type(tex) == 'string' or type(tex) == 'number' then
    local t = parent:CreateTexture()
    t:SetTexture(tex)
    return t
  else
    return tex
  end
end

local function mkBaseUIObjectTypes(api, loader)
  local function u(x)
    return api.UserData(x)
  end

  local function m(obj, f, ...)
    return getmetatable(obj).__index[f](obj, ...)
  end

  local function UpdateVisible(obj)
    local ud = u(obj)
    local pv = not ud.parent or u(ud.parent).visible
    local nv = pv and ud.shown
    if ud.visible ~= nv then
      ud.visible = nv
      api.RunScript(obj, nv and 'OnShow' or 'OnHide')
      for k in pairs(ud.children or {}) do
        UpdateVisible(k)
      end
    end
  end

  local function flatten(types)
    local result = {}
    local function flattenOne(k)
      local lk = string.lower(k)
      if not result[lk] then
        local ty = types[k]
        local inherits = {}
        local metaindex = Mixin({}, ty.mixin)
        for _, inh in ipairs(ty.inherits) do
          flattenOne(inh)
          table.insert(inherits, string.lower(inh))
          Mixin(metaindex, result[string.lower(inh)].metatable.__index)
        end
        result[lk] = {
          constructor = function(self)
            for _, inh in ipairs(inherits) do
              result[inh].constructor(self)
            end
            if ty.constructor then
              ty.constructor(self)
            end
          end,
          inherits = inherits,
          metatable = { __index = metaindex },
          name = k,
        }
      end
    end
    for k in pairs(types) do
      flattenOne(k)
    end
    return result
  end

  return flatten({
    Actor = {
      inherits = {'ParentedObject', 'ScriptObject'},
    },
    Alpha = {
      inherits = {'Animation'},
      mixin = {
        SetFromAlpha = UNIMPLEMENTED,
        SetToAlpha = UNIMPLEMENTED,
      },
    },
    Animation = {
      inherits = {'ParentedObject', 'ScriptObject'},
      mixin = {
        SetDuration = UNIMPLEMENTED,
        SetOrder = UNIMPLEMENTED,
        SetStartDelay = UNIMPLEMENTED,
      },
    },
    AnimationGroup = {
      constructor = function(self)
        u(self).animations = {}
      end,
      inherits = {'ParentedObject', 'ScriptObject'},
      mixin = {
        CreateAnimation = function(self, type)
          local ltype = (type or 'animation'):lower()
          assert(api.InheritsFrom(ltype, 'animation'))
          local anim = api.CreateUIObject(ltype)
          table.insert(u(self).animations, anim)
          return anim
        end,
        GetAnimations = function(self)
          return unpack(u(self).animations)
        end,
        IsPlaying = UNIMPLEMENTED,
        Play = UNIMPLEMENTED,
        SetToFinalAlpha = UNIMPLEMENTED,
        Stop = UNIMPLEMENTED,
      },
    },
    Browser = {
      inherits = {'Frame'},
      mixin = {
        NavigateHome = UNIMPLEMENTED,
      },
    },
    Button = {
      constructor = function(self)
        u(self).beingClicked = false
        u(self).buttonLocked = false
        u(self).buttonState = 'NORMAL'
        u(self).enabled = true
        u(self).fontstring = m(self, 'CreateFontString')
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
          return u(self).fontstring
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
        GetText = UNIMPLEMENTED,
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
        SetFontString = UNIMPLEMENTED,
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
        SetText = UNIMPLEMENTED,
        UnlockHighlight = UNIMPLEMENTED,
      },
    },
    CheckButton = {
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
    },
    CinematicModel = {
      inherits = {'PlayerModel'},
      mixin = {
        SetFacingLeft = UNIMPLEMENTED,
        SetHeightFactor = UNIMPLEMENTED,
        SetTargetDistance = UNIMPLEMENTED,
      },
    },
    ColorSelect = {
      inherits = {'Frame'},
      mixin = {
        GetColorRGB = UNIMPLEMENTED,
        SetColorRGB = UNIMPLEMENTED,
      },
    },
    Cooldown = {
      inherits = {'Frame'},
      mixin = {
        Clear = UNIMPLEMENTED,
        Pause = UNIMPLEMENTED,
        SetBlingTexture = function(self, tex)
          u(self).blingTexture = toTexture(self, tex)
        end,
        SetCooldown = UNIMPLEMENTED,
        SetDrawBling = UNIMPLEMENTED,
        SetDrawEdge = UNIMPLEMENTED,
        SetDrawSwipe = UNIMPLEMENTED,
        SetEdgeTexture = function(self, tex)
          u(self).edgeTexture = toTexture(self, tex)
        end,
        SetHideCountdownNumbers = UNIMPLEMENTED,
        SetReverse = UNIMPLEMENTED,
        SetSwipeColor = UNIMPLEMENTED,
        SetSwipeTexture = function(self, tex)
          u(self).swipeTexture = toTexture(self, tex)
        end,
      },
    },
    DressUpModel = {
      inherits = {'PlayerModel'},
      mixin = {
        SetAutoDress = UNIMPLEMENTED,
      },
    },
    EditBox = {
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
    },
    FogOfWarFrame = {
      inherits = {'Frame'},
      mixin = {
        GetUiMapID = UNIMPLEMENTED,
        SetUiMapID = UNIMPLEMENTED,
      },
    },
    Font = {
      inherits = {'FontInstance'},
      mixin = {
        CopyFontObject = UNIMPLEMENTED,
      },
    },
    FontInstance = {
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
    },
    FontString = {
      inherits = {'FontInstance', 'LayeredRegion'},
      mixin = {
        GetLineHeight = STUB_NUMBER,
        GetNumLines = STUB_NUMBER,
        GetStringHeight = STUB_NUMBER,
        GetStringWidth = STUB_NUMBER,
        GetUnboundedStringWidth = STUB_NUMBER,
        GetText = UNIMPLEMENTED,
        GetWrappedWidth = STUB_NUMBER,
        IsTruncated = UNIMPLEMENTED,
        SetFormattedText = UNIMPLEMENTED,
        SetMaxLines = UNIMPLEMENTED,
        SetNonSpaceWrap = UNIMPLEMENTED,
        SetText = UNIMPLEMENTED,
        SetTextHeight = UNIMPLEMENTED,
      },
    },
    Frame = {
      constructor = function(self)
        table.insert(api.frames, self)
        u(self).attributes = {}
        u(self).frameIndex = #api.frames
        u(self).frameLevel = 1
        u(self).frameStrata = 'MEDIUM'
        u(self).hyperlinksEnabled = false
        u(self).id = 0
        u(self).isClampedToScreen = false
        u(self).isUserPlaced = false
        u(self).mouseClickEnabled = true
        u(self).mouseMotionEnabled = true
        u(self).mouseWheelEnabled = false
        u(self).movable = false
        u(self).registeredAllEvents = false
        u(self).registeredEvents = {}
        u(self).resizable = false
        u(self).toplevel = false
      end,
      inherits = {'ParentedObject', 'Region', 'ScriptObject'},
      mixin = {
        CreateFontString = function(self, name)
          return api.CreateUIObject('fontstring', name, self)
        end,
        CreateMaskTexture = function(self)
          return api.CreateUIObject('masktexture', nil, self)
        end,
        CreateTexture = function(self, name)
          return api.CreateUIObject('texture', name, self)
        end,
        DesaturateHierarchy = UNIMPLEMENTED,
        EnableMouse = function(self, value)
          local ud = u(self)
          ud.mouseClickEnabled = not not value
          ud.mouseMotionEnabled = not not value
        end,
        EnableMouseWheel = function(self, value)
          u(self).mouseWheelEnabled = not not value
        end,
        GetAttribute = function(self, arg1, arg2, arg3)
          local attrs = u(self).attributes
          if arg3 then
            local keys = {
              arg1 .. arg2 .. arg3,
              '*' .. arg2 .. arg3,
              arg1 .. arg2 .. '*',
              '*' .. arg2 .. '*',
              arg2,
            }
            for _, k in ipairs(keys) do
              if attrs[k] then
                return attrs[k]
              end
            end
            return nil
          else
            return attrs[arg1]
          end
        end,
        GetChildren = function(self)
          local ret = {}
          for kid in pairs(u(self).children) do
            if api.InheritsFrom(u(kid).type, 'frame') then
              table.insert(ret, kid)
            end
          end
          return unpack(ret)
        end,
        GetFrameLevel = function(self)
          return u(self).frameLevel
        end,
        GetFrameStrata = function(self)
          return u(self).frameStrata
        end,
        GetHyperlinksEnabled = function(self)
          return u(self).hyperlinksEnabled
        end,
        GetID = function(self)
          return u(self).id
        end,
        GetMaxResize = function(self)
          return u(self).maxResizeWidth, u(self).maxResizeHeight
        end,
        GetMinResize = function(self)
          return u(self).minResizeWidth, u(self).minResizeHeight
        end,
        GetNumChildren = function(self)
          return select('#', m(self, 'GetChildren'))
        end,
        GetRegions = UNIMPLEMENTED,
        IgnoreDepth = UNIMPLEMENTED,
        IsClampedToScreen = function(self)
          return u(self).isClampedToScreen
        end,
        IsEventRegistered = function(self, event)
          local ud = u(self)
          return ud.registeredAllEvents or not not ud.registeredEvents[string.lower(event)]
        end,
        IsMouseClickEnabled = function(self)
          return u(self).mouseClickEnabled
        end,
        IsMouseEnabled = function(self)
          local ud = u(self)
          return ud.mouseClickEnabled and ud.mouseMotionEnabled
        end,
        IsMouseMotionEnabled = function(self)
          return u(self).mouseMotionEnabled
        end,
        IsMouseWheelEnabled = function(self)
          return u(self).mouseWheelEnabled
        end,
        IsMovable = function(self)
          return u(self).movable
        end,
        IsResizable = function(self)
          return u(self).resizable
        end,
        IsToplevel = function(self)
          return u(self).toplevel
        end,
        IsUserPlaced = function(self)
          return u(self).isUserPlaced
        end,
        Raise = UNIMPLEMENTED,
        RegisterAllEvents = function(self)
          u(self).registeredAllEvents = true
        end,
        RegisterEvent = function(self, event)
          u(self).registeredEvents[string.lower(event)] = true
        end,
        RegisterForDrag = UNIMPLEMENTED,
        RegisterForMouse = UNIMPLEMENTED,
        RegisterUnitEvent = function(self, event)  -- unit1, unit2
          -- TODO actually do unit filtering
          u(self).registeredEvents[string.lower(event)] = true
        end,
        SetAttribute = function(self, name, value)
          api.log(4, 'setting attribute %s on %s to %s', name, tostring(self:GetName()), tostring(value))
          u(self).attributes[name] = value
          api.RunScript(self, 'OnAttributeChanged', name, value)
        end,
        SetBackdrop = loader.version == 'Vanilla' and UNIMPLEMENTED or nil,
        SetBackdropBorderColor = loader.version == 'Vanilla' and UNIMPLEMENTED or nil,
        SetBackdropColor = loader.version == 'Vanilla' and UNIMPLEMENTED or nil,
        SetClampedToScreen = function(self, value)
          u(self).isClampedToScreen = not not value
        end,
        SetClampRectInsets = UNIMPLEMENTED,
        SetClipsChildren = UNIMPLEMENTED,
        SetDontSavePosition = UNIMPLEMENTED,
        SetFixedFrameLevel = loader.version ~= 'Vanilla' and UNIMPLEMENTED or nil,
        SetFixedFrameStrata = loader.version ~= 'Vanilla' and UNIMPLEMENTED or nil,
        SetFrameLevel = function(self, frameLevel)
          u(self).frameLevel = frameLevel
        end,
        SetFrameStrata = function(self, frameStrata)
          u(self).frameStrata = frameStrata
        end,
        SetHitRectInsets = UNIMPLEMENTED,
        SetHyperlinksEnabled = function(self, value)
          u(self).hyperlinksEnabled = not not value
        end,
        SetID = function(self, id)
          assert(type(id) == 'number', 'invalid ID ' .. tostring(id))
          u(self).id = id
        end,
        SetMaxResize = function(self, maxWidth, maxHeight)
          u(self).maxResizeWidth = maxWidth
          u(self).maxResizeHeight = maxHeight
        end,
        SetMinResize = function(self, minWidth, minHeight)
          u(self).minResizeWidth = minWidth
          u(self).minResizeHeight = minHeight
        end,
        SetMouseClickEnabled = function(self, value)
          u(self).mouseClickEnabled = not not value
        end,
        SetMouseMotionEnabled = function(self, value)
          u(self).mouseMotionEnabled = not not value
        end,
        SetMovable = function(self, value)
          u(self).movable = not not value
        end,
        SetResizable = function(self, value)
          u(self).resizable = not not value
        end,
        SetToplevel = function(self, value)
          u(self).toplevel = not not value
        end,
        SetUserPlaced = function(self, value)
          u(self).isUserPlaced = not not value
        end,
        StartMoving = UNIMPLEMENTED,
        UnregisterAllEvents = function(self)
          u(self).registeredAllEvents = false
          util.twipe(u(self).registeredEvents)
        end,
        UnregisterEvent = function(self, event)
          u(self).registeredEvents[string.lower(event)] = nil
        end,
      },
    },
    GameTooltip = {
      inherits = {'Frame'},
      mixin = {
        AddFontStrings = UNIMPLEMENTED,
        AddLine = UNIMPLEMENTED,
        ClearLines = UNIMPLEMENTED,
        FadeOut = UNIMPLEMENTED,
        GetOwner = function(self)
          return u(self).tooltipOwner
        end,
        IsOwned = function(self)
          return u(self).tooltipOwner ~= nil
        end,
        SetAction = UNIMPLEMENTED,
        SetAnchorType = UNIMPLEMENTED,
        SetBackpackToken = UNIMPLEMENTED,
        SetBagItem = UNIMPLEMENTED,
        SetHyperlink = UNIMPLEMENTED,
        SetInventoryItem = UNIMPLEMENTED,
        SetMinimumWidth = UNIMPLEMENTED,
        SetOwner = function(self, owner)
          u(self).tooltipOwner = owner
        end,
        SetPadding = UNIMPLEMENTED,
        SetShapeshift = UNIMPLEMENTED,
        SetText = UNIMPLEMENTED,
        SetUnit = UNIMPLEMENTED,
      },
    },
    LayeredRegion = {
      inherits = {'Region'},
      mixin = {
        SetDrawLayer = UNIMPLEMENTED,
        SetVertexColor = UNIMPLEMENTED,
      },
    },
    MaskTexture = {
      inherits = {'Texture'},
    },
    MessageFrame = {
      inherits = {'Frame'},
    },
    Minimap = {
      inherits = {'Frame'},
      mixin = {
        GetZoom = STUB_NUMBER,
        GetZoomLevels = STUB_NUMBER,
        SetMaskTexture = UNIMPLEMENTED,
        SetZoom = UNIMPLEMENTED,
      },
    },
    Model = {
      inherits = {'Frame'},
      mixin = {
        InitializeCamera = UNIMPLEMENTED,
        SetFacing = UNIMPLEMENTED,
        SetLight = UNIMPLEMENTED,
        SetPosition = UNIMPLEMENTED,
        SetRotation = UNIMPLEMENTED,
        TransformCameraSpaceToModelSpace = UNIMPLEMENTED,
      },
    },
    ModelScene = {
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
    },
    OffScreenFrame = {
      inherits = {'Frame'},
    },
    ParentedObject = {
      constructor = function(self)
        u(self).children = {}
        u(self).forbidden = false
      end,
      inherits = {'UIObject'},
      mixin = {
        GetDebugName = UNIMPLEMENTED,
        GetParent = function(self)
          return u(self).parent
        end,
        IsForbidden = function(self)
          return u(self).forbidden
        end,
        SetForbidden = function(self)
          u(self).forbidden = true
        end,
      },
    },
    Path = {
      inherits = {'Animation'},
    },
    PlayerModel = {
      inherits = {'Model'},
      mixin = {
        FreezeAnimation = UNIMPLEMENTED,
        RefreshCamera = UNIMPLEMENTED,
        RefreshUnit = UNIMPLEMENTED,
        SetAnimation = UNIMPLEMENTED,
        SetCamDistanceScale = UNIMPLEMENTED,
        SetDisplayInfo = UNIMPLEMENTED,
        SetDoBlend = UNIMPLEMENTED,
        SetKeepModelOnHide = UNIMPLEMENTED,
        SetPortraitZoom = UNIMPLEMENTED,
        SetUnit = UNIMPLEMENTED,
      },
    },
    POIFrame = {
      inherits = {'Frame'},
      mixin = {
        DrawNone = UNIMPLEMENTED,
        SetBorderAlpha = UNIMPLEMENTED,
        SetBorderScalar = UNIMPLEMENTED,
        SetBorderTexture = UNIMPLEMENTED,
        SetFillAlpha = UNIMPLEMENTED,
        SetFillTexture = UNIMPLEMENTED,
        SetMapID = UNIMPLEMENTED,
      },
    },
    QuestPOIFrame = {
      inherits = {'POIFrame'},
    },
    Region = {
      constructor = function(self)
        local ud = u(self)
        ud.alpha = 1
        ud.animationGroups = {}
        ud.bottom = 0
        ud.explicitlyProtected = false
        ud.height = 0
        ud.isIgnoringParentAlpha = false
        ud.isIgnoringParentScale = false
        ud.left = 0
        ud.points = {}
        ud.protected = false
        ud.scale = 1
        ud.shown = true
        ud.visible = not ud.parent or u(ud.parent).visible
        ud.width = 0
      end,
      inherits = {'ParentedObject'},
      mixin = {
        AdjustPointsOffset = UNIMPLEMENTED,
        ClearAllPoints = function(self)
          util.twipe(u(self).points)
        end,
        CreateAnimationGroup = function(self)
          local group = api.CreateUIObject('animationgroup')
          table.insert(u(self).animationGroups, group)
          return group
        end,
        GetAlpha = function(self)
          return u(self).alpha
        end,
        GetAnimationGroups = function(self)
          return unpack(u(self).animationGroups)
        end,
        GetBottom = function(self)
          return u(self).bottom
        end,
        GetCenter = function()
          return 1, 1  -- UNIMPLEMENTED
        end,
        GetEffectiveAlpha = function(self)
          local ud = u(self)
          if not ud.parent or ud.isIgnoringParentAlpha then
            return ud.alpha
          else
            return m(ud.parent, 'GetEffectiveAlpha') * ud.alpha
          end
        end,
        GetEffectiveScale = function(self)
          local ud = u(self)
          if not ud.parent or ud.isIgnoringParentScale then
            return ud.scale
          else
            return m(ud.parent, 'GetEffectiveScale') * ud.scale
          end
        end,
        GetHeight = function(self)
          return u(self).height
        end,
        GetLeft = function(self)
          return u(self).left
        end,
        GetNumPoints = function(self)
          return #u(self).points
        end,
        GetPoint = function(self, index)
          local idx
          if type(index) == 'string' then
            local i = 1
            while not idx and i <= #u(self).points do
              if u(self).points[i][1] == index then
                idx = i
              end
              i = i + 1
            end
          else
            idx = index or 1
          end
          if u(self).points[idx] then
            return unpack(u(self).points[idx])
          else
            api.log(1, 'returning fake point')
            return 'CENTER', api.env.UIParent, 'CENTER', 0, 0
          end
        end,
        GetRect = function(self)
          local ud = u(self)
          return ud.bottom, ud.left, ud.width, ud.height
        end,
        GetRight = function(self)
          return u(self).left + u(self).width
        end,
        GetScale = function(self)
          return u(self).scale
        end,
        GetScaledRect = function(self)
          local s = m(self, 'GetEffectiveScale')
          local b, l, w, h = m(self, 'GetRect')
          return b * s, l * s, w * s, h * s
        end,
        GetSize = function(self)
          return m(self, 'GetWidth'), m(self, 'GetHeight')
        end,
        GetTop = function(self)
          return u(self).bottom + u(self).height
        end,
        GetWidth = function(self)
          return u(self).width
        end,
        Hide = function(self)
          m(self, 'SetShown', false)
        end,
        IsIgnoringParentAlpha = function(self)
          return u(self).isIgnoringParentAlpha
        end,
        IsIgnoringParentScale = function(self)
          return u(self).isIgnoringParentScale
        end,
        IsMouseOver = UNIMPLEMENTED,
        IsProtected = function(self)
          return u(self).protected, u(self).explicitlyProtected
        end,
        IsShown = function(self)
          return u(self).shown
        end,
        IsVisible = function(self)
          return u(self).visible
        end,
        SetAllPoints = UNIMPLEMENTED,
        SetAlpha = function(self, alpha)
          u(self).alpha = alpha < 0 and 0 or alpha > 1 and 1 or alpha
        end,
        SetHeight = function(self, height)
          u(self).height = height
        end,
        SetIgnoreParentAlpha = function(self, ignore)
          u(self).isIgnoringParentAlpha = not not ignore
        end,
        SetParent = function(self, parent)
          if type(parent) == 'string' then
            parent = api.env[parent]
          end
          api.SetParent(self, parent)
          UpdateVisible(self)
        end,
        SetPoint = function(self, point, arg1, arg2, arg3, arg4)
          -- TODO handle resetting points
          local p
          if type(arg2) == 'string' then
            p = { point, type(arg1) == 'string' and api.env[arg1] or arg1, arg2, arg3, arg4 }
          else
            p = { point, u(self).parent, point, arg1, arg2 }
          end
          table.insert(u(self).points, p)
        end,
        SetScale = function(self, scale)
          if scale > 0 then
            u(self).scale = scale
          end
        end,
        SetShown = function(self, shown)
          u(self).shown = shown
          UpdateVisible(self)
        end,
        SetSize = UNIMPLEMENTED,
        SetWidth = function(self, width)
          u(self).width = width
        end,
        Show = function(self)
          m(self, 'SetShown', true)
        end,
      },
    },
    Rotation = {
      inherits = {'Animation'},
      mixin = {
        SetDegrees = UNIMPLEMENTED,
      },
    },
    Scale = {
      inherits = {'Animation'},
    },
    ScriptObject = {
      constructor = function(self)
        u(self).scripts = {
          [0] = {},
          [1] = {},
          [2] = {},
        }
      end,
      inherits = {},
      mixin = {
        GetScript = function(self, name, bindingType)
          return u(self).scripts[bindingType or 1][string.lower(name)]
        end,
        HasScript = function()
          return true  -- UNIMPLEMENTED
        end,
        HookScript = function(self, name, script, bindingType)
          local btype = bindingType or 1
          local lname = string.lower(name)
          local scripts = u(self).scripts[btype]
          local old = scripts[lname]
          if not old and btype ~= 1 then
            api.log(1, 'cannot hook nonexistent intrinsic precall/postcall')
            return false
          end
          scripts[lname] = function(...)
            if old then
              old(...)
            end
            script(...)
          end
          return true
        end,
        SetScript = function(self, name, script)
          api.SetScript(self, name, 1, script)
        end,
      },
    },
    ScenarioPOIFrame = {
      inherits = {'POIFrame'},
    },
    ScrollFrame = {
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
    },
    SimpleHTML = {
      inherits = {'FontInstance', 'Frame'},
      mixin = {
        SetText = UNIMPLEMENTED,
      },
    },
    Slider = {
      constructor = function(self)
        local ud = u(self)
        ud.enabled = true
        ud.max = 0
        ud.min = 0
        ud.value = 0
      end,
      inherits = {'Frame'},
      mixin = {
        Disable = function(self)
          u(self).enabled = false
        end,
        Enable = function(self)
          u(self).enabled = true
        end,
        GetMinMaxValues = function(self)
          local ud = u(self)
          return ud.min, ud.max
        end,
        GetOrientation = UNIMPLEMENTED,
        GetThumbTexture = function(self)
          return u(self).thumbTexture
        end,
        GetValue = function(self)
          return u(self).value
        end,
        IsDraggingThumb = UNIMPLEMENTED,
        SetMinMaxValues = function(self, min, max)
          local ud = u(self)
          ud.min = min
          ud.max = max
        end,
        SetStepsPerPage = UNIMPLEMENTED,
        SetThumbTexture = function(self, tex)
          u(self).thumbTexture = toTexture(self, tex)
        end,
        SetValue = function(self, value)
          u(self).value = value
        end,
        SetValueStep = UNIMPLEMENTED,
      },
    },
    StatusBar = {
      constructor = function(self)
        local ud = u(self)
        ud.max = 0
        ud.min = 0
        ud.value = 0
      end,
      inherits = {'Frame'},
      mixin = {
        GetMinMaxValues = function(self)
          local ud = u(self)
          return ud.min, ud.max
        end,
        GetStatusBarTexture = function(self)
          return u(self).statusBarTexture
        end,
        GetValue = function(self)
          return u(self).value
        end,
        SetMinMaxValues = function(self, min, max)
          local ud = u(self)
          ud.min = min
          ud.max = max
        end,
        SetOrientation = UNIMPLEMENTED,
        SetReverseFill = UNIMPLEMENTED,
        SetStatusBarColor = UNIMPLEMENTED,
        SetStatusBarTexture = function(self, tex)
          if type(tex) == 'number' then
            api.log(1, 'unimplemented call to SetStatusBarTexture')
            u(self).statusBarTexture = m(self, 'CreateTexture')
          else
            u(self).statusBarTexture = toTexture(self, tex)
          end
        end,
        SetValue = function(self, value)
          u(self).value = value
        end,
      },
    },
    Texture = {
      inherits = {'LayeredRegion', 'ParentedObject'},
      mixin = {
        GetTexCoord = function()
          return 0, 0, 0, 0, 0, 0, 0, 0  -- UNIMPLEMENTED
        end,
        GetTexture = UNIMPLEMENTED,
        GetVertexColor = UNIMPLEMENTED,
        SetAtlas = UNIMPLEMENTED,
        SetBlendMode = UNIMPLEMENTED,
        SetColorTexture = UNIMPLEMENTED,
        SetDesaturated = UNIMPLEMENTED,
        SetDesaturation = UNIMPLEMENTED,
        SetGradient = UNIMPLEMENTED,
        SetHorizTile = UNIMPLEMENTED,
        SetRotation = UNIMPLEMENTED,
        SetSnapToPixelGrid = UNIMPLEMENTED,
        SetTexCoord = UNIMPLEMENTED,
        SetTexelSnappingBias = UNIMPLEMENTED,
        SetTexture = UNIMPLEMENTED,
        SetVertTile = UNIMPLEMENTED,
      },
    },
    TextureCoordTranslation = {
      inherits = {'Animation'},
    },
    Translation = {
      inherits = {'Animation'},
      mixin = {
        SetOffset = UNIMPLEMENTED,
      },
    },
    UIObject = {
      inherits = {},
      mixin = {
        GetName = function(self)
          return u(self).name
        end,
        GetObjectType = function(self)
          return api.uiobjectTypes[u(self).type].name
        end,
        IsObjectType = function(self, ty)
          return api.InheritsFrom(u(self).type, string.lower(ty))
        end,
      },
    },
    UnitPositionFrame = {
      inherits = {'Frame'},
      mixin = {
        AddUnit = UNIMPLEMENTED,
        ClearUnits = UNIMPLEMENTED,
        FinalizeUnits = UNIMPLEMENTED,
        GetMouseOverUnits = UNIMPLEMENTED,
        SetPlayerPingScale = UNIMPLEMENTED,
        SetPlayerPingTexture = UNIMPLEMENTED,
        SetUiMapID = UNIMPLEMENTED,
        StartPlayerPing = UNIMPLEMENTED,
        StopPlayerPing = UNIMPLEMENTED,
      },
    },
    WorldFrame = {
      inherits = {'Frame'},
    },
  })
end

local function stringFormat(fmt, ...)
  local args = {...}
  for i, arg in ipairs(args) do
    fmt = fmt:gsub('%%' .. i .. '%$', arg)
  end
  return string.format(fmt, ...)
end

local function mkBaseEnv()
  return {
    abs = math.abs,
    assert = assert,
    bit = {
      band = bitlib.band,
      bnot = bitlib.bnot,
      bor = bitlib.bor,
    },
    ceil = math.ceil,
    date = os.date,
    debugstack = debug.traceback,
    error = error,
    floor = math.floor,
    format = stringFormat,
    getmetatable = getmetatable,
    getn = table.getn,
    gsub = string.gsub,
    ipairs = ipairs,
    loadstring = loadstring,
    loadstring_untainted = loadstring,
    math = {
      abs = math.abs,
      ceil = math.ceil,
      cos = math.cos,
      floor = math.floor,
      huge = math.huge,
      max = math.max,
      min = math.min,
      pi = math.pi,
      pow = math.pow,
      rad = math.rad,
      sin = math.sin,
      sqrt = math.sqrt,
    },
    max = math.max,
    min = math.min,
    mod = math.fmod,
    newproxy = newproxy,
    next = next,
    pairs = pairs,
    pcall = pcall,
    PI = math.pi,
    print = print,
    rad = math.rad,
    random = math.random,
    rawget = rawget,
    rawset = rawset,
    select = select,
    setfenv = setfenv,
    setmetatable = setmetatable,
    sort = table.sort,
    strfind = string.find,
    string = {
      byte = string.byte,
      char = string.char,
      find = string.find,
      format = stringFormat,
      gmatch = string.gmatch,
      gsub = string.gsub,
      join = util.strjoin,
      len = string.len,
      lower = string.lower,
      match = string.match,
      rep = string.rep,
      sub = string.sub,
      trim = util.strtrim,
      upper = string.upper,
    },
    strbyte = string.byte,
    strjoin = util.strjoin,
    strlen = string.len,
    strlenutf8 = string.len, -- NEEDS ACTUAL FUNCTION
    strlower = string.lower,
    strmatch = string.match,
    strrep = string.rep,
    strsplit = util.strsplit,
    strsub = string.sub,
    strtrim = util.strtrim,
    strupper = string.upper,
    table = {
      concat = table.concat,
      insert = table.insert,
      remove = table.remove,
      sort = table.sort,
      wipe = util.twipe,
    },
    tinsert = table.insert,
    tonumber = tonumber,
    tostring = tostring,
    tremove = table.remove,
    type = type,
    unpack = unpack,
    wipe = util.twipe,
    xpcall = function(f, e, ...)
      local args = {...}
      return xpcall(function() f(unpack(args)) end, e)
    end,
  }
end

local function mkMetaEnv(api)
  local __dump = (function()
    local block = require('serpent').block
    local config = { nocode = true }
    local function dump(x)
      print(block(x, config))
    end
    return function(...)
      for _, x in ipairs({...}) do
        dump(x)
        if api.UserData(x) then
          print('===[begin userdata]===')
          dump(api.UserData(x))
          print('===[ end userdata ]===')
        end
      end
    end
  end)()
  return {
    __index = {
      _G = api.env,
      __dump = __dump,
    },
  }
end

local function mkWowEnv(api, loader)
  local function CreateFrame(type, name, parent, templateNames)
    local ltype = string.lower(type)
    assert(api.IsIntrinsicType(ltype), type .. ' is not intrinsic')
    assert(api.InheritsFrom(ltype, 'frame'), type .. ' does not inherit from frame')
    local templates = {}
    for templateName in string.gmatch(templateNames or '', '[^, ]+') do
      local template = api.templates[string.lower(templateName)]
      assert(template, 'unknown template ' .. templateName)
      table.insert(templates, template)
    end
    return api.CreateUIObject(ltype, name, parent, nil, unpack(templates))
  end
  return {
    BreakUpLargeNumbers = tostring,  -- UNIMPLEMENTED,
    CreateFont = function(name)
      return api.CreateUIObject('font', name)
    end,
    CreateForbiddenFrame = CreateFrame,
    CreateFrame = CreateFrame,
    C_AdventureMap = {},
    EnumerateFrames = function(frame)
      if frame == nil then
        return api.frames[1]
      else
        local idx = api.UserData(frame).frameIndex
        return idx ~= #api.frames and api.frames[idx+1] or nil
      end
    end,
    GetChatWindowInfo = function(idx)
      return '', 10, 1, 1, 1, 1, 1, 1, idx  -- UNIMPLEMENTED
    end,
    geterrorhandler = function()
      return api.ErrorHandler  -- UNIMPLEMENTED
    end,
    GetFactionInfoByID = function(id)
      return 'faction' .. id, nil, nil, nil, nil, 0  -- UNIMPLEMENTED
    end,
    GetInventorySlotInfo = (function()
      local t = {
        ammoslot = 0,
        headslot = 1,
        neckslot = 2,
        shoulderslot = 3,
        shirtslot = 4,
        chestslot = 5,
        waistslot = 6,
        legsslot = 7,
        feetslot = 8,
        wristslot = 9,
        handsslot = 10,
        finger0slot = 11,
        finger1slot = 12,
        trinket0slot = 13,
        trinket1slot = 14,
        backslot = 15,
        mainhandslot = 16,
        secondaryhandslot = 17,
        rangedslot = 18,
        tabardslot = 19,
        bag0slot = 20,
        bag1slot = 21,
        bag2slot = 22,
        bag3slot = 23,
      }
      return function(slotName)
        return assert(t[string.lower(slotName)], 'unknown slot name ' .. slotName)
      end
    end)(),
    GetItemClassInfo = function(classID)
      return string.format('ItemClass%d', classID)
    end,
    GetItemInventorySlotInfo = function(inventorySlot)
      return string.format('ItemInventorySlot%d', inventorySlot)
    end,
    GetItemQualityColor = (function()
      local data = {
        [0] = { 0x9d, 0x9d, 0x9d },  -- Poor
        [1] = { 0xff, 0xff, 0xff },  -- Common
        [2] = { 0x1e, 0xff, 0x00 },  -- Uncommon
        [3] = { 0x00, 0x70, 0xdd },  -- Rare
        [4] = { 0xa3, 0x35, 0xee },  -- Epic
        [5] = { 0xff, 0x80, 0x00 },  -- Legendary
        [6] = { 0xe6, 0xcc, 0x80 },  -- Artifact
        [7] = { 0x00, 0xcc, 0xff },  -- Heirloom
        [8] = { 0x00, 0xcc, 0xff },  -- WoW Token
      }
      local returns = {}
      for k, v in pairs(data) do
        local r, g, b = unpack(v)
        returns[k] = { r / 255, g / 255, b / 255, string.format('%2x%2x%2x', r, g, b) }
      end
      return function(i)
        return unpack(returns[i])
      end
    end)(),
    GetItemSubClassInfo = function(classID, subClassID)
      return string.format('ItemClass%dSubClass%d', classID, subClassID)
    end,
    GetText = function(token)
      return 'GetText(' .. token .. ')'  -- UNIMPLEMENTED
    end,
    IsLoggedIn = function()
      return api.isLoggedIn
    end,
    issecure = function()
      -- use tainted-lua if available
      return issecure and issecure() or true
    end,
    LoadAddOn = function(name)
      assert(name)
      loader.loadAddon(name)
      return true
    end,
    RunMacroText = function(s)
      for _, line in ipairs({util.strsplit('\n', s)}) do
        api.SendEvent('EXECUTE_CHAT_LINE', line)
      end
    end,
    scrub = function(...)
      return ...  -- UNIMPLEMENTED
    end,
    securecall = function(func, ...)
      assert(func, 'securecall of nil function')
      if type(func) == 'string' then
        assert(api.env[func], 'securecall of unknown function ' .. func)
        func = api.env[func]
      end
      -- use tainted-lua if available
      if securecall then
        return securecall(func, ...)
      else
        return func(...)
      end
    end,
  }
end

local function init(api, loader)
  setmetatable(api.env, mkMetaEnv(api))
  Mixin(api.env, mkBaseEnv())
  util.recursiveMixin(api.env, require('wowapi.loader').loadFunctions('data/api', loader.version, api.env), true)
  util.recursiveMixin(api.env, mkWowEnv(api, loader), true)
  Mixin(api.uiobjectTypes, mkBaseUIObjectTypes(api, loader))
end

return {
  init = init,
}
