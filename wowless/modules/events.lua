local hlist = require('wowless.hlist')
return function(datalua)
  local allregs = hlist()
  local regs = {}
  for k in pairs(datalua.events) do
    regs[k] = hlist()
  end

  local function RegisterEvent(frame, event)
    event = event:upper()
    local reg = assert(regs[event], 'cannot register ' .. event)
    if allregs:has(frame) or reg:has(frame) then
      return false
    end
    reg:insert(frame)
    return true
  end

  local function UnregisterEvent(frame, event)
    event = event:upper()
    local reg = assert(regs[event], 'cannot unregister ' .. event)
    reg:remove(frame)
  end

  local function UnregisterAllEvents(frame)
    for _, reg in pairs(regs) do
      reg:remove(frame)
    end
    allregs:remove(frame)
  end

  local function RegisterAllEvents(frame)
    UnregisterAllEvents(frame)
    allregs:insert(frame)
  end

  local function IsEventRegistered(frame, event)
    return allregs:has(frame) or regs[event:upper()]:has(frame), nil
  end

  local function IsEventValid(event)
    return not not regs[event:upper()]
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

  return {
    GetFramesRegisteredForEvent = GetFramesRegisteredForEvent,
    GetFramesRegisteredForEventUnpacked = GetFramesRegisteredForEventUnpacked,
    IsEventRegistered = IsEventRegistered,
    IsEventValid = IsEventValid,
    RegisterAllEvents = RegisterAllEvents,
    RegisterEvent = RegisterEvent,
    UnregisterAllEvents = UnregisterAllEvents,
    UnregisterEvent = UnregisterEvent,
  }
end
