return function(log, luaobjects, security)
  local stamp = 1234
  local timers = require('minheap'):new()
  timers:push(math.huge, function()
    error('fell off the end of time')
  end)

  local function addTimer(seconds, callback)
    timers:push(stamp + seconds, callback)
  end

  local function newTicker(seconds, obj, iterations)
    assert(seconds >= 0 and seconds < 4294968) -- (2 ^ 32 - 1) / 1000
    obj.seconds = seconds
    obj.count = 0
    obj.iterations = iterations
    addTimer(seconds, obj)
    return obj
  end

  local function Advance(elapsed)
    stamp = stamp + elapsed
    while timers:peek().pri < stamp do
      local timer = timers:pop()
      local obj = timer.val
      log(2, 'running timer %.2f %s', timer.pri, tostring(obj))
      if not obj.cancelled and obj.count < obj.iterations then
        security.CallSandbox(obj.callback, luaobjects.CreateProxy('LuaFunctionContainer', obj))
        obj.count = obj.count + 1
        addTimer(obj.seconds, obj)
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
