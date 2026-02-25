return function(api, luaobjects, uiobjects, uiobjecttypes)
  local stringenums = require('runtime.stringenums')

  local function CheckStringEnum(value, enumname)
    local evalues = stringenums[enumname]
    return evalues and evalues[value:upper()]
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

  local function IsUiObject(ud, typename)
    local internal = uiobjects.userdata[ud]
    return internal and uiobjecttypes.IsObjectType(internal, typename)
  end

  return {
    CheckStringEnum = CheckStringEnum,
    CreateLuaObject = CreateLuaObject,
    CreateUiObject = CreateUiObject,
    IsLuaObject = IsLuaObject,
    IsUiObject = IsUiObject,
  }
end
