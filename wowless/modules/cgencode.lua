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

  local function ImplInputLuaObject(value, typename)
    local coerced = luaobjects.Coerce(typename, value)
    if coerced then
      return coerced
    end
    local internal = luaobjects.UserData(value)
    if internal and internal.type == typename then
      return internal
    end
    error('expected luaobject ' .. typename)
  end

  local function ImplOutputLuaObject(internal, typename)
    if type(internal) ~= 'table' or internal.type ~= typename then
      error('impl output type error: expected luaobject ' .. typename)
    end
    return internal.luarep
  end

  local function ImplOutputUiObject(internal, typename)
    if type(internal) ~= 'table' or not uiobjecttypes.IsObjectType(internal, typename) then
      error('impl output type error: expected uiobject ' .. typename)
    end
    return internal.luarep
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
    ImplInputLuaObject = ImplInputLuaObject,
    ImplOutputLuaObject = ImplOutputLuaObject,
    ImplOutputUiObject = ImplOutputUiObject,
    CreateLuaObject = CreateLuaObject,
    CreateUiObject = CreateUiObject,
    IsLuaObject = IsLuaObject,
    IsUiObject = IsUiObject,
    log = log,
  }
end
