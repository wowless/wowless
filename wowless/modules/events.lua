local hlist = require('wowless.hlist')
return function(datalua, funcheck, log, loglevel, scripts)
  local allregs = hlist()
  local regs = {}
  for k in pairs(datalua.events) do
    regs[k] = hlist()
  end

  local function RegisterEvent(frame, event)
    event = event:upper()
    local reg = assert(regs[event], 'cannot register ' .. event)
    if reg:has(frame) then
      return false
    end
    reg:insert(frame)
    return true
  end

  local function UnregisterEvent(frame, event)
    event = event:upper()
    local reg = assert(regs[event], 'cannot unregister ' .. event)
    if reg:has(frame) then
      reg:remove(frame)
      return true
    end
    return false
  end

  local function UnregisterAllEvents(frame)
    for _, reg in pairs(regs) do
      reg:remove(frame)
    end
    allregs:remove(frame)
  end

  local function RegisterAllEvents(frame)
    allregs:insert(frame)
  end

  local function IsEventRegistered(frame, event)
    return regs[event:upper()]:has(frame), nil
  end

  local function IsEventValid(event)
    return not not regs[event:upper()]
  end

  local function IsCallbackEvent(event)
    local e = datalua.events[event:upper()]
    return e and e.callback or false
  end

  local function GetFramesRegisteredForEvent(event)
    event = event:upper()
    local ret = {}
    local reg = regs[event]
    if reg then
      for frame in reg:entries() do
        table.insert(ret, frame)
      end
    end
    for frame in allregs:entries() do
      table.insert(ret, frame)
    end
    return ret
  end

  local function GetFramesRegisteredForEventUnpacked(event)
    return unpack(GetFramesRegisteredForEvent(event))
  end

  local echecks = setmetatable({}, {
    __index = function(t, k)
      local e = datalua.events[k]
      local v = funcheck.makeCheckOutputs(k, {
        outputs = e.payload,
        outstride = e.stride,
      })
      t[k] = v
      return v
    end,
  })

  local function DoSendEvent(event, ...)
    for _, reg in ipairs(GetFramesRegisteredForEvent(event)) do
      scripts.RunScript(reg, 'OnEvent', event, ...)
    end
  end

  local function SendEvent(event, ...)
    if not IsEventValid(event) then
      error('internal error: cannot send ' .. event)
    end
    if loglevel >= 1 then
      local largs = {}
      for i = 1, select('#', ...) do
        local arg = select(i, ...)
        table.insert(largs, type(arg) == 'string' and ('%q'):format(arg) or tostring(arg))
      end
      log(1, 'sending event %s (%s)', event, table.concat(largs, ', '))
    end
    DoSendEvent(event, echecks[event](...))
  end

  return {
    GetFramesRegisteredForEvent = GetFramesRegisteredForEvent,
    GetFramesRegisteredForEventUnpacked = GetFramesRegisteredForEventUnpacked,
    IsCallbackEvent = IsCallbackEvent,
    IsEventRegistered = IsEventRegistered,
    IsEventValid = IsEventValid,
    RegisterAllEvents = RegisterAllEvents,
    RegisterEvent = RegisterEvent,
    RegisterUnitEvent = RegisterEvent, -- TODO implement properly
    SendEvent = SendEvent,
    UnregisterAllEvents = UnregisterAllEvents,
    UnregisterEvent = UnregisterEvent,
  }
end
