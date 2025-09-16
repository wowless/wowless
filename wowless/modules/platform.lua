local platform = require('runtime.platform')

return function()
  local function IsLinuxClient()
    return platform == 'linux'
  end
  local function IsMacClient()
    return platform == 'mac'
  end
  local function IsWindowsClient()
    return platform == 'windows'
  end
  return {
    IsLinuxClient = IsLinuxClient,
    IsMacClient = IsMacClient,
    IsWindowsClient = IsWindowsClient,
    platform = platform,
  }
end
