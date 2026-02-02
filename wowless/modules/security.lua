local traceback = require('wowless.ext').traceback
return function(log, maxErrors)
  local errors = 0

  local function ErrorHandler(str)
    errors = errors + 1
    log(0, 'error: ' .. str .. '\n' .. traceback())
    if errors >= maxErrors then
      log(0, 'maxerrors reached, quitting')
      os.exit(0)
    end
  end

  local function assertHostMode()
    local tm = debug.gettaintmode()
    if tm ~= 'disabled' then
      error(('wowless bug: host taint mode %q'):format(tm))
    end
    local st = debug.getstacktaint()
    if st ~= nil then
      error(('wowless bug: host stack taint %q'):format(st))
    end
  end

  local function assertSandboxMode()
    local tm = debug.gettaintmode()
    if tm ~= 'rw' then
      error(('wowless bug: sandbox taint mode %q'):format(tm))
    end
  end

  local function CallSafely(fun, ...)
    assertHostMode()
    assert(getfenv(fun) == _G, 'wowless bug: expected framework function')
    xpcall(fun, ErrorHandler, ...)
    assertHostMode()
  end

  local function postSandbox(...)
    assertSandboxMode()
    debug.settaintmode('disabled')
    debug.setstacktaint(nil)
    assertHostMode()
    return ...
  end

  local function CallSandbox(fun, ...)
    assertHostMode()
    assert(getfenv(fun) ~= _G, 'wowless bug: expected sandbox function')
    debug.settaintmode('rw')
    return postSandbox(xpcall(fun, ErrorHandler, ...))
  end

  local function GetErrorCount()
    return errors
  end

  return {
    CallSafely = CallSafely,
    CallSandbox = CallSandbox,
    GetErrorCount = GetErrorCount,
  }
end
