return function(uiobjects, uiobjecttypes)
  local function IsUiObject(ud, typename)
    local internal = uiobjects.userdata[ud]
    return internal and uiobjecttypes.IsObjectType(internal, typename)
  end

  return {
    IsUiObject = IsUiObject,
  }
end
