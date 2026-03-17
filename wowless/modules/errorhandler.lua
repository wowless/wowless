return function(events)
  local SendEvent = events.SendEvent
  local pendingWarnings = {}
  local currentFn
  local realseterrorhandler = seterrorhandler

  local function geterrorhandler()
    return currentFn
  end

  local function seterrorhandler(fn)
    if type(fn) ~= 'function' then
      -- Pass non-functions through to the real seterrorhandler, which will
      -- reject them with an error, preserving the previous handler.
      realseterrorhandler(fn)
      return
    end
    currentFn = fn
    realseterrorhandler(function(msg)
      local ok, result = pcall(fn, msg)
      if not ok then
        table.insert(pendingWarnings, tostring(result))
      end
    end)
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
