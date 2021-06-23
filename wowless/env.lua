local util = require('wowless.util')
local Mixin = util.mixin

local UNIMPLEMENTED = function() end
local STUB_NUMBER = function() return 1 end

local function mkBaseUIObjectTypes(api)
  return {
    actor = {
      inherits = {'parentedobject', 'scriptobject'},
      intrinsic = true,
      name = 'Actor',
    },
    animationgroup = {
      inherits = {'parentedobject'},
      intrinsic = true,
      name = 'AnimationGroup',
    },
    button = {
      constructor = function(self)
        self.__fontstring = self:CreateFontString()
      end,
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        Disable = UNIMPLEMENTED,
        Enable = UNIMPLEMENTED,
        GetFontString = function(self)
          return self.__fontstring
        end,
        GetTextWidth = STUB_NUMBER,
        IsEnabled = UNIMPLEMENTED,
        LockHighlight = UNIMPLEMENTED,
        RegisterForClicks = UNIMPLEMENTED,
        SetDisabledFontObject = UNIMPLEMENTED,
        SetDisabledTexture = UNIMPLEMENTED,
        SetEnabled = UNIMPLEMENTED,
        SetHighlightFontObject = UNIMPLEMENTED,
        SetHighlightTexture = UNIMPLEMENTED,
        SetNormalFontObject = UNIMPLEMENTED,
        SetNormalTexture = UNIMPLEMENTED,
        SetPushedTexture = UNIMPLEMENTED,
        SetText = UNIMPLEMENTED,
        UnlockHighlight = UNIMPLEMENTED,
      },
      name = 'Button',
    },
    checkbutton = {
      inherits = {'button'},
      intrinsic = true,
      mixin = {
        SetChecked = UNIMPLEMENTED,
      },
      name = 'CheckButton',
    },
    cooldown = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        SetSwipeColor = UNIMPLEMENTED,
      },
      name = 'Cooldown',
    },
    dressupmodel = {
      inherits = {'playermodel'},
      intrinsic = true,
      name = 'DressUpModel',
    },
    editbox = {
      inherits = {'frame'},
      intrinsic = true,
      name = 'EditBox',
    },
    font = {
      inherits = {'fontinstance'},
      intrinsic = true,
      name = 'Font',
    },
    fontinstance = {
      inherits = {'uiobject'},
      intrinsic = true,
      mixin = {
        GetFont = UNIMPLEMENTED,
        SetFontObject = UNIMPLEMENTED,
        SetJustifyH = UNIMPLEMENTED,
        SetSpacing = UNIMPLEMENTED,
        SetTextColor = UNIMPLEMENTED,
      },
      name = 'FontInstance',
    },
    fontstring = {
      inherits = {'fontinstance', 'layeredregion'},
      intrinsic = true,
      mixin = {
        GetText = UNIMPLEMENTED,
        SetText = UNIMPLEMENTED,
      },
      name = 'FontString',
    },
    frame = {
      constructor = function(self)
        self.__attributes = {}
      end,
      inherits = {'parentedobject', 'region', 'scriptobject'},
      intrinsic = true,
      mixin = {
        CreateFontString = function(self, name)
          return api:CreateUIObject('fontstring', name, self)
        end,
        CreateTexture = function(self, name)
          return api:CreateUIObject('texture', name, self)
        end,
        EnableMouse = UNIMPLEMENTED,
        GetAttribute = function(self, name)
          return self.__attributes[name]
        end,
        GetFrameLevel = STUB_NUMBER,
        GetID = STUB_NUMBER,
        IgnoreDepth = UNIMPLEMENTED,
        IsEventRegistered = UNIMPLEMENTED,
        RegisterEvent = UNIMPLEMENTED,
        RegisterForDrag = UNIMPLEMENTED,
        RegisterUnitEvent = UNIMPLEMENTED,
        SetAttribute = function(self, name, value)
          local old = self.__attributes[name]
          if old ~= value then
            api.log(4, 'setting %s to %s', name, tostring(value))
            self.__attributes[name] = value
            local script = self:GetScript('OnAttributeChanged')
            if script then
              script(self, name, value)
            end
          end
        end,
        SetClampRectInsets = UNIMPLEMENTED,
        SetFrameLevel = UNIMPLEMENTED,
        SetFrameStrata = UNIMPLEMENTED,
        SetHitRectInsets = UNIMPLEMENTED,
        SetMouseClickEnabled = UNIMPLEMENTED,
        SetID = UNIMPLEMENTED,
      },
      name = 'Frame',
    },
    gametooltip = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        GetOwner = UNIMPLEMENTED,
        IsOwned = UNIMPLEMENTED,
      },
      name = 'GameTooltip',
    },
    layeredregion = {
      inherits = {'region'},
      intrinsic = true,
      mixin = {
        SetDrawLayer = UNIMPLEMENTED,
        SetVertexColor = UNIMPLEMENTED,
      },
      name = 'LayeredRegion',
    },
    messageframe = {
      inherits = {'frame'},
      intrinsic = true,
      name = 'MessageFrame',
    },
    model = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        SetRotation = UNIMPLEMENTED,
      },
      name = 'Model',
    },
    modelscene = {
      inherits = {'frame'},
      intrinsic = true,
      name = 'ModelScene',
    },
    parentedobject = {
      inherits = {'uiobject'},
      intrinsic = true,
      mixin = {
        GetParent = function(self)
          return self.__parent
        end,
        SetForbidden = UNIMPLEMENTED,
      },
      name = 'ParentedObject',
    },
    playermodel = {
      inherits = {'model'},
      intrinsic = true,
      name = 'PlayerModel',
    },
    region = {
      inherits = {'parentedobject'},
      intrinsic = true,
      mixin = {
        ClearAllPoints = UNIMPLEMENTED,
        GetEffectiveScale = STUB_NUMBER,
        GetHeight = STUB_NUMBER,
        GetNumPoints = function()
          return 0  -- UNIMPLEMENTED
        end,
        GetPoint = UNIMPLEMENTED,
        GetWidth = STUB_NUMBER,
        Hide = UNIMPLEMENTED,
        IsShown = UNIMPLEMENTED,
        SetAlpha = UNIMPLEMENTED,
        SetHeight = UNIMPLEMENTED,
        SetParent = UNIMPLEMENTED,
        SetPoint = UNIMPLEMENTED,
        SetScale = UNIMPLEMENTED,
        SetShown = UNIMPLEMENTED,
        SetSize = UNIMPLEMENTED,
        SetWidth = UNIMPLEMENTED,
        Show = UNIMPLEMENTED,
      },
      name = 'Region',
    },
    scriptobject = {
      constructor = function(self)
        self.__scripts = {
          [0] = {},
          [1] = {},
          [2] = {},
        }
      end,
      inherits = {},
      intrinsic = true,
      mixin = {
        GetScript = function(self, name, bindingType)
          return self.__scripts[bindingType or 1][string.lower(name)]
        end,
        SetScript = function(self, name, script)
          self.__scripts[1][string.lower(name)] = script
        end,
      },
      name = 'ScriptObject',
    },
    scrollframe = {
      inherits = {'frame'},
      intrinsic = true,
      name = 'ScrollFrame',
    },
    slider = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        GetMinMaxValues = UNIMPLEMENTED,
        SetMinMaxValues = UNIMPLEMENTED,
        SetValue = UNIMPLEMENTED,
      },
      name = 'Slider',
    },
    statusbar = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        GetMinMaxValues = function()
          return 0, 0  -- UNIMPLEMENTED
        end,
        GetStatusBarTexture = UNIMPLEMENTED,
        GetValue = function()
          return 0  -- UNIMPLEMENTED
        end,
        SetMinMaxValues = UNIMPLEMENTED,
        SetStatusBarColor = UNIMPLEMENTED,
        SetStatusBarTexture = UNIMPLEMENTED,
        SetValue = UNIMPLEMENTED,
      },
      name = 'StatusBar',
    },
    texture = {
      inherits = {'layeredregion', 'parentedobject'},
      intrinsic = true,
      mixin = {
        GetTexCoord = UNIMPLEMENTED,
        SetDesaturated = UNIMPLEMENTED,
        SetTexCoord = UNIMPLEMENTED,
        SetTexture = UNIMPLEMENTED,
      },
      name = 'Texture',
    },
    uiobject = {
      inherits = {},
      intrinsic = true,
      mixin = {
        GetName = function(self)
          return self.__name
        end,
      },
      name = 'UIObject',
    },
    worldframe = {
      inherits = {'frame'},
      intrinsic = true,
      name = 'WorldFrame',
    },
  }
end

local function _InheritsFrom(api, a, b)
  local result = a == b
  for _, inh in ipairs(api.uiobjectTypes[a].inherits) do
    result = result or _InheritsFrom(api, inh, b)
  end
  return result
end

local function _IsIntrinsicType(api, t)
  local type = api.uiobjectTypes[string.lower(t)]
  return type and type.intrinsic
end

local function _IsUIObjectType(api, t)
  return api.uiobjectTypes[string.lower(t)] ~= nil
end

local function mixinType(api, type, obj)
  for _, inh in ipairs(type.inherits) do
    assert(api.uiobjectTypes[inh], inh .. ' is not a uiobject type')
    mixinType(api, api.uiobjectTypes[inh], obj)
  end
  api.log(4, 'mixing in ' .. type.name)
  Mixin(obj, type.mixin)
  if type.constructor then
    type.constructor(obj)
  end
  return obj
end

local function _CreateUIObject(api, typename, objname, parent, inherits)
  assert(typename, 'must specify type for ' .. tostring(objname))
  local type = api.uiobjectTypes[typename]
  assert(type, 'unknown type ' .. typename .. ' for ' .. tostring(objname))
  api.log(3, 'creating %s%s', type.name, objname and (' named ' .. objname) or '')
  local obj = {
    __name = objname,
    __parent = parent,
  }
  mixinType(api, type, obj)
  for _, inh in ipairs(inherits or {}) do
    local inhtype = api.uiobjectTypes[inh]
    assert(inhtype, 'unknown inherit type ' .. inh .. ' for ' .. tostring(objname))
    mixinType(api, inhtype, obj)
  end
  if objname then
    if api.env[objname] then
      api.log(1, 'overwriting global ' .. objname)
    end
    api.env[objname] = obj
  end
  return obj
end

local function mkBaseEnv()
  local bitlib = require('bit')
  return setmetatable({
    assert = assert,
    bit = {
      bor = bitlib.bor,
    },
    ceil = math.ceil,
    getfenv = getfenv,
    getmetatable = getmetatable,
    getn = table.getn,
    ipairs = ipairs,
    math = {
      max = math.max,
    },
    max = math.max,
    next = next,
    pairs = pairs,
    pcall = pcall,
    print = print,
    rawget = rawget,
    select = select,
    setmetatable = setmetatable,
    sort = table.sort,
    string = {
      find = string.find,
      format = string.format,
      gmatch = string.gmatch,
      gsub = string.gsub,
      len = string.len,
      lower = string.lower,
      match = string.match,
      rep = string.rep,
      sub = string.sub,
      upper = string.upper,
    },
    strlower = string.lower,
    strsub = string.sub,
    strupper = string.upper,
    table = {
      insert = table.insert,
      wipe = util.twipe,
    },
    tinsert = table.insert,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
  }, {
    __index = function(t, k)
      if k == '_G' then
        return t
      elseif string.sub(k, 1, 3) == 'LE_' then
        return 'AUTOGENERATED:' .. k
      end
    end
  })
end

local function mkWowEnv(api)
  return {
    AntiAliasingSupported = UNIMPLEMENTED,
    CreateFrame = function(type, name)
      local ltype = string.lower(type)
      assert(_InheritsFrom(api, ltype, 'frame'), type .. ' does not inherit from frame')
      return _CreateUIObject(api, ltype, name)
    end,
    C_CVar = {
      GetCVar = UNIMPLEMENTED,
      GetCVarBool = UNIMPLEMENTED,
      GetCVarDefault = UNIMPLEMENTED,
    },
    C_Club = {},
    C_GamePad = {},
    C_ScriptedAnimations = {
      GetAllScriptedAnimationEffects = function()
        return {}  -- UNIMPLEMENTED
      end,
    },
    C_Social = {
      TwitterCheckStatus = UNIMPLEMENTED,
    },
    C_StorePublic = {
      IsDisabledByParentalControls = UNIMPLEMENTED,
    },
    C_Timer = {
      After = UNIMPLEMENTED,
    },
    C_VoiceChat = {
      GetAvailableInputDevices = UNIMPLEMENTED,
      GetAvailableOutputDevices = UNIMPLEMENTED,
      GetCommunicationMode = UNIMPLEMENTED,
      GetInputVolume = UNIMPLEMENTED,
      GetMasterVolumeScale = UNIMPLEMENTED,
      GetOutputVolume = UNIMPLEMENTED,
      GetVADSensitivity = UNIMPLEMENTED,
    },
    C_Widget = {},
    DropCursorMoney = UNIMPLEMENTED,
    Enum = setmetatable({}, {
      __index = function(_, k)
        return setmetatable({}, {
          __index = function(_, k2)
            return 'AUTOGENERATED:Enum:' .. k .. ':' .. k2
          end,
        })
      end,
    }),
    FillLocalizedClassList = UNIMPLEMENTED,
    format = string.format,
    GetActionBarPage = STUB_NUMBER,
    GetActionCount = STUB_NUMBER,
    GetActionInfo = UNIMPLEMENTED,
    GetActionTexture = UNIMPLEMENTED,
    GetAddOnEnableState = UNIMPLEMENTED,
    GetAvailableLocales = UNIMPLEMENTED,
    GetBindingKey = UNIMPLEMENTED,
    GetBindingText = UNIMPLEMENTED,
    GetChatTypeIndex = STUB_NUMBER,
    GetChatWindowInfo = UNIMPLEMENTED,
    GetCVarInfo = UNIMPLEMENTED,
    GetCVarSettingValidity = UNIMPLEMENTED,
    GetDefaultLanguage = function()
      return 'Common', 7  -- UNIMPLEMENTED
    end,
    GetDefaultVideoOptions = UNIMPLEMENTED,
    GetGameTime = UNIMPLEMENTED,
    GetInventorySlotInfo = function()
      return 'UNIMPLEMENTED'
    end,
    GetItemQualityColor = function()
      return 0, 0, 0  -- UNIMPLEMENTED
    end,
    GetLootMethod = function()
      return 'freeforall'  -- UNIMPLEMENTED
    end,
    GetMaxRenderScale = UNIMPLEMENTED,
    GetMinRenderScale = UNIMPLEMENTED,
    GetModifiedClick = UNIMPLEMENTED,
    GetNumAddOns = function()
      return 0  -- UNIMPLEMENTED
    end,
    GetText = UNIMPLEMENTED,
    HasAction = UNIMPLEMENTED,
    IsAddonVersionCheckEnabled = UNIMPLEMENTED,
    IsAltKeyDown = UNIMPLEMENTED,
    IsConsumableAction = UNIMPLEMENTED,
    IsControlKeyDown = UNIMPLEMENTED,
    IsEquippedAction = UNIMPLEMENTED,
    IsGMClient = UNIMPLEMENTED,
    IsInGroup = UNIMPLEMENTED,
    IsInGuild = UNIMPLEMENTED,
    IsInInstance = UNIMPLEMENTED,
    IsItemAction = UNIMPLEMENTED,
    IsMacClient = UNIMPLEMENTED,
    IsOnGlueScreen = UNIMPLEMENTED,
    issecure = UNIMPLEMENTED,
    IsShiftKeyDown = UNIMPLEMENTED,
    IsStackableAction = UNIMPLEMENTED,
    IsTrialAccount = UNIMPLEMENTED,
    IsVeteranTrialAccount = UNIMPLEMENTED,
    IsWindowsClient = UNIMPLEMENTED,
    Kiosk = {
      IsEnabled = UNIMPLEMENTED,
    },
    MultiSampleAntiAliasingSupported = UNIMPLEMENTED,
    newproxy = function()
      return setmetatable({}, {})
    end,
    NUM_LE_ITEM_QUALITYS = 10,  -- UNIMPLEMENTED
    PlaySound = UNIMPLEMENTED,
    RegisterStaticConstants = UNIMPLEMENTED,
    securecall = function(func, ...)
      assert(func, 'securecall of nil function')
      if type(func) == 'string' then
        assert(api.env[func], 'securecall of unknown function ' .. func)
        func = api.env[func]
      end
      func(...)
    end,
    SetActionUIButton = UNIMPLEMENTED,
    seterrorhandler = UNIMPLEMENTED,
    SetPortraitTexture = UNIMPLEMENTED,
    ShouldKnowUnitHealth = UNIMPLEMENTED,
    ShowBossFrameWhenUninteractable = UNIMPLEMENTED,
    Sound_GameSystem_GetNumOutputDrivers = STUB_NUMBER,
    Sound_GameSystem_GetOutputDriverNameByIndex = UNIMPLEMENTED,
    UnitExists = UNIMPLEMENTED,
    UnitHealthMax = STUB_NUMBER,
    UnitIsConnected = UNIMPLEMENTED,
    UnitIsDead = UNIMPLEMENTED,
    UnitIsGhost = UNIMPLEMENTED,
    UnitIsGroupLeader = UNIMPLEMENTED,
    UnitIsVisible = UNIMPLEMENTED,
    UnitName = function()
      return 'Unitname'  -- UNIMPLEMENTED
    end,
    UnitPower = STUB_NUMBER,
    UnitPowerMax = STUB_NUMBER,
    UnitPowerType = function()
      return 0, 'MANA'  -- UNIMPLEMENTED
    end,
    UnitRace = function()
      return 'Human', 'Human', 1  -- UNIMPLEMENTED
    end,
    UnitRealmRelationship = UNIMPLEMENTED,
    UnitSex = function()
      return 2  -- UNIMPLEMENTED
    end,
  }
end

local function new(log)
  local env = mkBaseEnv()
  local api = {
    CreateUIObject = _CreateUIObject,
    env = env,
    IsIntrinsicType = _IsIntrinsicType,
    IsUIObjectType = _IsUIObjectType,
    log = log,
  }
  api.uiobjectTypes = mkBaseUIObjectTypes(api)
  Mixin(env, mkWowEnv(api), require('wowless.globalstrings'))
  return env, api
end

return {
  new = new,
}
