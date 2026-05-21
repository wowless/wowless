local bubblewrap = require('wowless.bubblewrap')

return function(addons, api, events, log, luaobjects, uiobjects, units)
  local function CreateLuaObject(typename)
    return luaobjects.CreateProxy(typename, luaobjects.Create(typename))
  end

  local function CreateUiObject(typename)
    return api.CreateUIObject(string.lower(typename)).luarep
  end

  local function GetUiAddon(value)
    return addons.addons[tonumber(value) or tostring(value):lower()]
  end

  local function FireProtected(taint)
    events.SendEvent('ADDON_ACTION_FORBIDDEN', taint, 'UNKNOWN()')
  end

  -- Index 1 is accessed from C via lua_rawgeti for hot-path array-part
  -- lookups (no hashing). Keep uiobjects.userdata at 1.
  return {
    uiobjects.userdata,
    FireProtected = bubblewrap(FireProtected),
    GetUiAddon = GetUiAddon,
    GetUnit = units.GetUnit,
    Coerce = luaobjects.Coerce,
    CreateLuaObject = CreateLuaObject,
    CreateProxy = luaobjects.CreateProxy,
    CreateUiObject = CreateUiObject,
    log = log,
  }
end
