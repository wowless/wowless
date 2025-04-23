-- TODO align with api implementations
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

local function bubblewrapup(stacktaint, success, ...)
  assertHostMode()
  debug.settaintmode('rw')
  debug.setstacktaint(stacktaint)
  if success then
    return ...
  else
    error(...)
  end
end

local function bubblewrap(fn)
  return function(...)
    assertSandboxMode()
    debug.settaintmode('disabled')
    local stacktaint = debug.getstacktaint()
    debug.setstacktaint(nil)
    return bubblewrapup(stacktaint, pcall(fn, ...))
  end
end

return bubblewrap
