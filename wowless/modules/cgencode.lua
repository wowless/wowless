local bubblewrap = require('wowless.bubblewrap')

return function(addons, api, events, log, luaobjects, uiobjects, units)
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

  local function GetUiAddon(value)
    return addons.addons[tonumber(value) or tostring(value):lower()]
  end

  local function FireProtected(taint)
    events.SendEvent('ADDON_ACTION_FORBIDDEN', taint, 'UNKNOWN()')
  end

  -- Index 1 is accessed from C via lua_rawgeti for a hot-path array-part lookup
  -- (no hashing). Keep uiobjects.userdata first; string keys below can shift freely.
  return {
    uiobjects.userdata,
    CheckStringEnum = CheckStringEnum,
    FireProtected = bubblewrap(FireProtected),
    GetUiAddon = GetUiAddon,
    GetUnit = units.GetUnit,
    ImplInputLuaObject = ImplInputLuaObject,
    ImplOutputLuaObject = ImplOutputLuaObject,
    CreateLuaObject = CreateLuaObject,
    CreateUiObject = CreateUiObject,
    IsLuaObject = IsLuaObject,
    log = log,
  }
end
