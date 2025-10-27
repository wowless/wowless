local bubblewrap = require('wowless.bubblewrap')

return function(datalua, security)
  local cfg = datalua.config.modules and datalua.config.modules.funtainer or {}

  local state = setmetatable({}, { __mode = 'k' })

  local function Cancel(p)
    state[p].cancelled = true
  end

  local function Invoke(p, ...)
    security.CallSandbox(state[p].callback, ...)
  end

  local function IsCancelled(p)
    return state[p].cancelled
  end

  local index = {
    Cancel = bubblewrap(Cancel),
    Invoke = bubblewrap(Invoke),
    IsCancelled = bubblewrap(IsCancelled),
  }

  local mt
  mt = {
    __eq = function(u1, u2)
      return state[u1].table == state[u2].table
    end,
    __index = function(u, k)
      return index[k] or state[u].table[k]
    end,
    __metatable = false,
    __newindex = function(u, k, v)
      if index[k] or mt[k] ~= nil then
        error('Attempted to assign to read-only key ' .. k)
      end
      state[u].table[k] = v
    end,
    __tostring = cfg.tostring_metamethod and function(u)
      return 'LuaFunctionContainer: ' .. tostring(state[u].table):sub(8)
    end,
  }

  local mtproxy = newproxy(true)
  require('wowless.util').mixin(getmetatable(mtproxy), mt)

  local function CreateCallback(callback)
    assert(getfenv(callback) ~= _G, 'wowless bug: framework callback in newTicker')
    local p = newproxy(mtproxy)
    state[p] = {
      callback = callback,
      cancelled = false,
      table = {},
    }
    return p
  end

  local function CreateProxy(p)
    local np = newproxy(p)
    state[np] = state[p]
    return np
  end

  return {
    CreateCallback = CreateCallback,
    CreateProxy = CreateProxy,
    Invoke = Invoke,
    IsCancelled = IsCancelled,
  }
end
