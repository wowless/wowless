return function(luaobjects, security)
  local function IsEligible(callback)
    return type(callback) == 'function' and not debug.iscfunction(callback)
  end

  local function construct(obj, callback)
    assert(IsEligible(callback), type(callback))
    assert(getfenv(callback) ~= _G, 'wowless bug: framework callback in newTicker')
    obj.callback = callback
    obj.cancelled = false
  end

  local function coerce(obj, value)
    if IsEligible(value) then
      construct(obj, value)
      return true
    end
  end

  local methods = {
    Cancel = function(obj)
      obj.cancelled = true
    end,
    Invoke = function(obj, ...)
      if not obj.cancelled then
        security.CallSandbox(obj.callback, ...)
      end
    end,
    IsCancelled = function(obj)
      return obj.cancelled
    end,
  }

  local function CreateCallback(callback)
    return luaobjects.Create('LuaFunctionContainer', callback)
  end

  return {
    CreateCallback = CreateCallback,
    coerce = coerce,
    construct = construct,
    methods = methods,
  }
end
