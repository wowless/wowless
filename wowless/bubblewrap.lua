local function bubblewrapup(taintmode, stacktaint, success, ...)
  debug.setstacktaint(stacktaint)
  debug.settaintmode(taintmode)
  if success then
    return ...
  else
    error(...)
  end
end

local function bubblewrap(fn)
  return function(...)
    local taintmode = debug.gettaintmode()
    debug.settaintmode('disabled')
    local stacktaint = debug.getstacktaint()
    debug.setstacktaint(nil)
    return bubblewrapup(taintmode, stacktaint, pcall(fn, ...))
  end
end

return bubblewrap
