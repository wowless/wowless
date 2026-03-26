return function(eventqueue)
  local QueueEvent = eventqueue.QueueEvent
  local currentFn

  seterrorhandler(function(msg)
    if not pcall(currentFn, msg) then
      QueueEvent('LUA_WARNING', msg)
    end
  end)

  local function geterrorhandler()
    return currentFn
  end

  local function seterrorhandler(fn)
    currentFn = fn
  end

  return {
    geterrorhandler = geterrorhandler,
    seterrorhandler = seterrorhandler,
  }
end
