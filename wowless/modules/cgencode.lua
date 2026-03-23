return function(addons, api, log, luaobjects, uiobjects, uiobjecttypes)
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

  return {
    CheckStringEnum = CheckStringEnum,
    GetUiAddon = GetUiAddon,
    CreateLuaObject = CreateLuaObject,
    CreateUiObject = CreateUiObject,
    IsLuaObject = IsLuaObject,
    IsUiObject = IsUiObject,
    log = log,
  }
end
