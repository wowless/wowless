return function(eventqueue, uiobjects)
  local QueueEvent = eventqueue.QueueEvent
  local UserData = uiobjects.UserData
  local currentFn

  -- elune's reference error handler (f_errorhandler/f_errorobjname in
  -- lbaselib.c) substitutes a "*:" script source token with the name of the
  -- frame found in the erroring function's first local, but only if that
  -- frame's userdata has a __name metamethod. Wowless's uiobject userdata is
  -- exposed directly to the sandbox and must stay bare (no metatable), so we
  -- replicate the substitution here instead, using wowless's own uiobject
  -- registry to resolve the name field (as GetClickFrame does; no
  -- substitution if the object has no name). Level 4 (relative to this
  -- function) is empirically the function that errored: 1 is this function,
  -- 2 is the dispatcher below, 3 is an elune-internal C frame that invokes
  -- the dispatcher on behalf of f_errorhandler, and 4 is the erroring
  -- function.
  local function SubstituteObjectName(msg)
    local s, e = string.find(msg, '*:', 1, true)
    if not s then
      return msg
    end
    local info = debug.getinfo(4, 'S')
    if not info or string.sub(info.source, 1, 1) ~= '*' then
      return msg
    end
    local _, frame = debug.getlocal(4, 1)
    if type(frame) ~= 'table' then
      return msg
    end
    local ud = UserData(frame)
    local name = ud and ud.name
    if not name then
      return msg
    end
    return string.sub(msg, 1, s - 1) .. name .. string.sub(msg, e)
  end

  seterrorhandler(function(msg)
    if type(msg) == 'string' then
      msg = SubstituteObjectName(msg)
    end
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
