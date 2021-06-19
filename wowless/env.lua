local util = require('wowless.util')
local Mixin = util.mixin

local UNIMPLEMENTED = function() end
local STUB_NUMBER = function() return 1 end

local function mkBaseUIObjectTypes(api)
  return {
    actor = {
      inherits = {'parentedobject'},
      intrinsic = true,
      name = 'Actor',
    },
    animationgroup = {
      inherits = {'parentedobject'},
      intrinsic = true,
      name = 'AnimationGroup',
    },
    button = {
      inherits = {'frame'},
      intrinsic = true,
      mixin = {
        Disable = UNIMPLEMENTED,
        IsEnabled = UNIMPLEMENTED,
        RegisterForClicks = UNIMPLEMENTED,
        SetText = UNIMPLEMENTED,
      },
      name = 'Button',
    },
    checkbutton = {
      inherits = {'button'},
      intrinsic = true,
      name = 'CheckButton',
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
        SetFontObject = UNIMPLEMENTED,
      },
      name = 'FontInstance',
    },
    fontstring = {
      inherits = {'fontinstance', 'layeredregion'},
      intrinsic = true,
      mixin = {
        SetText = UNIMPLEMENTED,
      },
      name = 'FontString',
    },
    frame = {
      inherits = {'parentedobject', 'region', 'scriptobject'},
      intrinsic = true,
      mixin = {
        CreateTexture = function(self, name)
          return api:CreateUIObject('texture', name, self)
        end,
        GetFrameLevel = STUB_NUMBER,
        GetID = STUB_NUMBER,
        IgnoreDepth = UNIMPLEMENTED,
        IsEventRegistered = UNIMPLEMENTED,
        RegisterEvent = UNIMPLEMENTED,
        RegisterForDrag = UNIMPLEMENTED,
        SetClampRectInsets = UNIMPLEMENTED,
        SetFrameLevel = UNIMPLEMENTED,
      },
      name = 'Frame',
    },
    gametooltip = {
      inherits = {'frame'},
      intrinsic = true,
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
    modelscene = {
      inherits = {'parentedobject'},
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
      inherits = {'parentedobject'},
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
        GetWidth = STUB_NUMBER,
        Hide = UNIMPLEMENTED,
        SetPoint = UNIMPLEMENTED,
        SetSize = UNIMPLEMENTED,
        Show = UNIMPLEMENTED,
      },
      name = 'Region',
    },
    scriptobject = {
      inherits = {},
      intrinsic = true,
      mixin = {
        GetScript = UNIMPLEMENTED,
        SetScript = UNIMPLEMENTED,
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
        GetMinMaxValues = UNIMPLEMENTED,
        SetMinMaxValues = UNIMPLEMENTED,
      },
      name = 'StatusBar',
    },
    texture = {
      inherits = {'layeredregion', 'parentedobject'},
      intrinsic = true,
      mixin = {
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
      api.log(0, 'overwriting global ' .. objname)
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
    getfenv = getfenv,
    getmetatable = getmetatable,
    ipairs = ipairs,
    math = {
      max = math.max,
    },
    max = math.max,
    pairs = pairs,
    rawget = rawget,
    select = select,
    setmetatable = setmetatable,
    string = {
      format = string.format,
      gmatch = string.gmatch,
      gsub = string.gsub,
      lower = string.lower,
      match = string.match,
      sub = string.sub,
      upper = string.upper,
    },
    table = {
      insert = table.insert,
      wipe = util.twipe,
    },
    tinsert = table.insert,
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
    CreateFrame = function(type, name)
      local ltype = string.lower(type)
      assert(_InheritsFrom(api, ltype, 'frame'), type .. ' does not inherit from frame')
      return _CreateUIObject(api, ltype, name)
    end,
    C_Club = {},
    C_GamePad = {},
    C_ScriptedAnimations = {
      GetAllScriptedAnimationEffects = function()
        return {}  -- UNIMPLEMENTED
      end,
    },
    C_Timer = {
      After = UNIMPLEMENTED,
    },
    C_VoiceChat = {},
    C_Widget = {},
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
    GetChatWindowInfo = UNIMPLEMENTED,
    GetCVarSettingValidity = UNIMPLEMENTED,
    GetDefaultVideoOptions = UNIMPLEMENTED,
    GetInventorySlotInfo = function()
      return 'UNIMPLEMENTED'
    end,
    GetItemQualityColor = function()
      return 0, 0, 0  -- UNIMPLEMENTED
    end,
    IsGMClient = UNIMPLEMENTED,
    IsOnGlueScreen = UNIMPLEMENTED,
    issecure = UNIMPLEMENTED,
    newproxy = function()
      return setmetatable({}, {})
    end,
    NUM_LE_ITEM_QUALITYS = 10,  -- UNIMPLEMENTED
    print = print,
    RegisterStaticConstants = UNIMPLEMENTED,
    securecall = UNIMPLEMENTED,
    seterrorhandler = UNIMPLEMENTED,
    UnitRace = function()
      return 'Human', 'Human', 1  -- UNIMPLEMENTED
    end,
    UnitSex = function()
      return 2  -- UNIMPLEMENTED
    end,
  }
end

local globalStrings = {
  -- luacheck: no max line length
  CONFIRM_CONTINUE = 'Do you wish to continue?',
  GUILD_REPUTATION_WARNING_GENERIC = 'You will lose one rank of guild reputation with your previous guild.',
  PRESS_TAB = 'Press Tab',
  REMOVE_GUILDMEMBER_LABEL = 'Are you sure you want to remove %s from the guild?',
  VOID_STORAGE_DEPOSIT_CONFIRMATION = 'Depositing this item will remove all modifications and make it non-refundable and non-tradeable.',
}

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
  Mixin(env, mkWowEnv(api), globalStrings)
  return env, api
end

return {
  new = new,
}
