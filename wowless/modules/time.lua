return function(funtainer, log, security)
  local stamp = 1234
  local timers = require('minheap'):new()
  timers:push(math.huge, function()
    error('fell off the end of time')
  end)

  local function addTimer(seconds, callback)
    timers:push(stamp + seconds, callback)
  end

  local function newTicker(seconds, callback, iterations)
    assert(seconds >= 0 and seconds < 5000000) -- TODO tighten this
    local p = funtainer.CreateCallback(callback)
    local count = 0
    local function cb()
      if not funtainer.IsCancelled(p) and count < iterations then
        funtainer.Invoke(p, funtainer.CreateProxy(p))
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
