return function(log, luaobjects, security)
  local stamp = 1234
  local timers = require('minheap'):new()
  timers:push(math.huge, function()
    error('fell off the end of time')
  end)

  local function addTimer(seconds, timer)
    timers:push(stamp + seconds, timer)
  end

  local function newTicker(seconds, callback, iterations)
    assert(seconds >= 0 and seconds < 4294968) -- (2 ^ 32 - 1) / 1000
    addTimer(seconds, {
      callback = callback,
      count = 0,
      iterations = iterations,
      seconds = seconds,
    })
    return callback
  end

  local function Advance(elapsed)
    stamp = stamp + elapsed
    while timers:peek().pri < stamp do
      local timer = timers:pop()
      local rec = timer.val
      local obj = rec.callback
      log(2, 'running timer %.2f %s', timer.pri, tostring(obj))
      if not obj.cancelled and rec.count < rec.iterations then
        security.CallSandbox(obj.callback, luaobjects.CreateProxy('LuaFunctionContainer', obj))
        rec.count = rec.count + 1
        addTimer(rec.seconds, rec)
      end
    end
  end

  return {
    Advance = Advance,
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
