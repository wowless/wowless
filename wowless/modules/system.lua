return function()
  local isLoggedIn = false
  local screenHeight = 720
  local screenWidth = 1280
  return {
    GetScreenHeight = function()
      return screenHeight
    end,
    GetScreenWidth = function()
      return screenWidth
    end,
    IsLoggedIn = function()
      return isLoggedIn
    end,
    LogIn = function()
      assert(not isLoggedIn)
      isLoggedIn = true
    end,
  }
end
