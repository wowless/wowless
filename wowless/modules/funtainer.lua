return function(luaobjects, security)
  local function IsEligible(callback)
    return type(callback) == 'function' and not debug.iscfunction(callback)
  end

  local function create(callback)
    assert(IsEligible(callback), type(callback))
    assert(getfenv(callback) ~= _G, 'wowless bug: framework callback in newTicker')
    return {
      callback = callback,
      cancelled = false,
    }
  end

  local function coerce(value)
    if IsEligible(value) then
      return create(value)
    end
  end

  local methods = {
    Cancel = function(state)
      state.cancelled = true
    end,
    Invoke = function(state, ...)
      if not state.cancelled then
        security.CallSandbox(state.callback, ...)
      end
    end,
    IsCancelled = function(state)
      return state.cancelled
    end,
  }

  local function CreateCallback(callback)
    return luaobjects.Create('LuaFunctionContainer', callback)
  end

  return {
    CreateCallback = CreateCallback,
    coerce = coerce,
    create = create,
    methods = methods,
  }
end
