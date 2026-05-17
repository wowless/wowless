local uiobject = require('wowless.uiobject')

return function()
  local userdata = {}
  local function UserData(obj)
    if type(obj) ~= 'table' then
      return nil
    end
    local token = rawget(obj, 0)
    if token == nil then
      return nil
    end
    local id = uiobject.id(token)
    return id and userdata[id]
  end
  return {
    userdata = userdata,
    UserData = UserData,
  }
end
