local function bubblewrapup(stacktaint, success, ...)
  debug.setstacktaint(stacktaint)
  debug.settaintmode('rw')
  if success then
    return ...
  else
    error(...)
  end
end

local function bubblewrap(fn)
  return function(...)
    debug.settaintmode('disabled')
    local stacktaint = debug.getstacktaint()
    debug.setstacktaint(nil)
    return bubblewrapup(stacktaint, pcall(fn, ...))
  end
end

return bubblewrap
