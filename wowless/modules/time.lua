local bubblewrap = require('wowless.bubblewrap')

return function(log, security)
  local stamp = 1234
  local timers = require('minheap'):new()
  timers:push(math.huge, function()
    error('fell off the end of time')
  end)

  local state = setmetatable({}, { __mode = 'k' })

  local index = {
    Cancel = bubblewrap(function(self)
      state[self].cancelled = true
    end),
    Invoke = bubblewrap(function(self, ...)
      state[self].callback(...)
    end),
    IsCancelled = bubblewrap(function(self)
      return state[self].cancelled
    end),
  }

  local tickerMT
  tickerMT = {
    __eq = function(u1, u2)
      return state[u1].table == state[u2].table
    end,
    __index = function(u, k)
      return index[k] or state[u].table[k]
    end,
    __metatable = false,
    __newindex = function(u, k, v)
      if index[k] or tickerMT[k] ~= nil then
        error('Attempted to assign to read-only key ' .. k)
      end
      state[u].table[k] = v
    end,
  }

  local mtproxy = newproxy(true)
  require('wowless.util').mixin(getmetatable(mtproxy), tickerMT)

  local function addTimer(seconds, callback)
    timers:push(stamp + seconds, callback)
  end

  local function newTicker(seconds, callback, iterations)
    assert(getfenv(callback) ~= _G, 'wowless bug: framework callback in newTicker')
    local p = newproxy(mtproxy)
    state[p] = {
      callback = callback,
      cancelled = false,
      table = {},
    }
    local count = 0
    local function cb()
      if not state[p].cancelled and count < iterations then
        local np = newproxy(p)
        state[np] = state[p]
        security.CallSandbox(callback, np)
        count = count + 1
        addTimer(seconds, cb)
      end
    end
    addTimer(seconds, cb)
    return p
  end

  return {
    AddTimer = addTimer,
    Advance = function(elapsed)
      stamp = stamp + (elapsed or 1)
      while timers:peek().pri < stamp do
        local timer = timers:pop()
        log(2, 'running timer %.2f %s', timer.pri, tostring(timer.val))
        assert(getfenv(timer.val) == _G, 'wowless bug: sandbox callback in time.Advance')
        security.CallSafely(timer.val)
      end
    end,
    ['C_Timer.After'] = function(seconds, callback)
      newTicker(seconds, callback, 1)
    end,
    ['C_Timer.NewTicker'] = function(seconds, callback, iterations)
      return newTicker(seconds, callback, iterations or 1)
    end,
    ['C_Timer.NewTimer'] = function(seconds, callback)
      return newTicker(seconds, callback, 1)
    end,
    GetTime = function()
      return stamp
    end,
  }
end
