local bubblewrap = require('wowless.bubblewrap')

return function(addons, api, events, log, luaobjects, uiobjects, uiobjecttypes, units)
  local stringenums = require('runtime.stringenums')

  local function CheckStringEnum(value, enumname)
    local evalues = stringenums[enumname]
    if not evalues then
      error('internal error: unknown string enum: ' .. enumname)
    end
    return evalues[value:upper()]
  end

  local function CreateLuaObject(typename)
    return luaobjects.Create(typename).luarep
  end

  local function CreateUiObject(typename)
    return api.CreateUIObject(string.lower(typename)).luarep
  end

  local function IsLuaObject(ud, typename)
    local internal = luaobjects.UserData(ud)
    return internal and internal.type == typename
  end

  local function GetUiAddon(value)
    return addons.addons[tonumber(value) or tostring(value):lower()]
  end

  local function IsUiObject(ud, typename)
    local internal = uiobjects.userdata[ud]
    return internal and uiobjecttypes.IsObjectType(internal, typename)
  end

  local function FireProtected(taint)
    events.SendEvent('ADDON_ACTION_FORBIDDEN', taint, 'UNKNOWN()')
  end

  return {
    CheckStringEnum = CheckStringEnum,
    FireProtected = bubblewrap(FireProtected),
    GetUiAddon = GetUiAddon,
    GetUnit = units.GetUnit,
    CreateLuaObject = CreateLuaObject,
    CreateUiObject = CreateUiObject,
    IsLuaObject = IsLuaObject,
    IsUiObject = IsUiObject,
    log = log,
  }
end
