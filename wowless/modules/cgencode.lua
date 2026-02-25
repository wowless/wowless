return function(luaobjects, uiobjects, uiobjecttypes)
  local function CreateLuaObject(typename)
    return luaobjects.Create(typename).luarep
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
    CreateLuaObject = CreateLuaObject,
    IsLuaObject = IsLuaObject,
    IsUiObject = IsUiObject,
  }
end
