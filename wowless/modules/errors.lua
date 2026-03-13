local debugstack = require('wowless.debug').debugstack
return function(log, maxErrors)
  local errors = 0

  local function ErrorHandler(str)
    errors = errors + 1
    log(0, 'error: ' .. str .. '\n' .. debugstack())
    if errors >= maxErrors then
      log(0, 'maxerrors reached, quitting')
      os.exit(0)
    end
  end

  local function GetErrorCount()
    return errors
  end

  return {
    ErrorHandler = ErrorHandler,
    GetErrorCount = GetErrorCount,
  }
end
