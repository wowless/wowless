return function(uiobjmodel)
  local userdata = {}
  local dynamicTypes = {} -- [lightuserdata] = lowercase intrinsic name
  local function UserData(obj)
    return userdata[obj[0]]
  end
  local function GetType(obj)
    return dynamicTypes[obj[0]] or uiobjmodel.GetTypeName(obj[0])
  end
  local function GetDynamicType(obj)
    return dynamicTypes[obj[0]]
  end
  local function SetDynamicType(obj, name)
    dynamicTypes[obj[0]] = name
  end
  return {
    GetDynamicType = GetDynamicType,
    GetType = GetType,
    SetDynamicType = SetDynamicType,
    userdata = userdata,
    UserData = UserData,
  }
end
