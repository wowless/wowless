local uiobject = require('wowless.uiobject')

return function()
  local userdata = {}
  local function UserData(obj)
    return userdata[uiobject.id(obj[0])]
  end
  return {
    userdata = userdata,
    UserData = UserData,
  }
end
