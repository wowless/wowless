return function(events)
  local SendEvent = events.SendEvent
  local pendingWarnings = {}
  local currentFn
  local realSeterrorhandler = seterrorhandler

  local function geterrorhandler()
    return currentFn
  end

  local function seterrorhandler(fn)
    currentFn = fn
    if type(fn) ~= 'function' then
      realSeterrorhandler(fn)
      return
    end
    realSeterrorhandler(function(msg)
      local ok, result = pcall(fn, msg)
      if ok then
        return result
      else
        table.insert(pendingWarnings, result or 'error in error handling')
        return msg
      end
    end)
  end

  local function FlushWarnings()
    while pendingWarnings[1] do
      SendEvent('LUA_WARNING', table.remove(pendingWarnings, 1))
    end
  end

  return {
    geterrorhandler = geterrorhandler,
    seterrorhandler = seterrorhandler,
    FlushWarnings = FlushWarnings,
  }
end
