return function(events)
  local SendEvent = events.SendEvent
  local pendingWarnings = {}
  local currentFn

  -- Set the real handler once; it always delegates to the current handler.
  seterrorhandler(function(msg)
    if not currentFn or not pcall(currentFn, msg) then
      table.insert(pendingWarnings, msg)
    end
  end)

  local function geterrorhandler()
    return currentFn
  end

  local function seterrorhandler(fn)
    currentFn = fn
  end

  local function FlushWarnings()
    for _, msg in ipairs(pendingWarnings) do
      SendEvent('LUA_WARNING', msg)
    end
    table.wipe(pendingWarnings)
  end

  return {
    geterrorhandler = geterrorhandler,
    seterrorhandler = seterrorhandler,
    FlushWarnings = FlushWarnings,
  }
end
