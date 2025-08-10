return function()
  local userdata = {}
  local function UserData(obj)
    return userdata[obj[0]]
  end
  return {
    userdata = userdata,
    UserData = UserData,
  }
end
