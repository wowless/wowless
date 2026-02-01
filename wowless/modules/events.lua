local hlist = require('wowless.hlist')
return function(datalua, funcheck, log, loglevel, scripts)
  local allregs = hlist()
  local regs = {}
  local cbregs = {}
  local secures = {}
  for k, v in pairs(datalua.events) do
    if not v.noscript then
      regs[k] = hlist()
    end
    if v.callback then
      cbregs[k] = hlist()
    end
    secures[k] = v.restricted
  end

  local function RegisterEvent(frame, event)
    local uevent = event:upper()
    local reg = regs[uevent]
    if not reg then
      local fmt = '%s:RegisterEvent(): %s:RegisterEvent(): Attempt to register unknown event %q'
      local ty = frame:GetObjectType()
      error(fmt:format(ty, ty, event), 0)
    end
    if reg:has(frame) or secures[uevent] and _G.THETAINT then
      return false
    end
    reg:insert(frame)
    return true
  end

  local function RegisterEventCallback(frame, event)
    local uevent = event:upper()
    local cbreg = cbregs[uevent]
    if not cbreg then
      local fmt = '%s:RegisterEventCallback(): Attempt to register unknown event %q'
      local ty = frame:GetObjectType()
      error(fmt:format(ty, event), 0)
    end
    if secures[uevent] and _G.THETAINT then -- TODO check repeat registration
      return false
    end
    -- TODO actually register the callback
    return true
  end

  local function RegisterEventCallbackGlobal(event)
    local uevent = event:upper()
    local cbreg = cbregs[uevent]
    if not cbreg then
      local fmt = 'RegisterEventCallback Attempt to register unknown event %q'
      local taint = _G.THETAINT and '\nLua Taint: ' .. _G.THETAINT or ''
      error(fmt:format(event) .. taint, 0)
    end
    if secures[uevent] and _G.THETAINT then -- TODO check repeat registration
      return false
    end
    -- TODO actually register the callback
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
    return not not cbregs[event:upper()]
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
    -- TODO invoke callbacks
  end

  local function SendEvent(event, ...)
    if not regs[event] and not cbregs[event] then
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
    RegisterEventCallback = RegisterEventCallback,
    RegisterEventCallbackGlobal = RegisterEventCallbackGlobal,
    RegisterUnitEvent = RegisterEvent, -- TODO implement properly
    SendEvent = SendEvent,
    UnregisterAllEvents = UnregisterAllEvents,
    UnregisterEvent = UnregisterEvent,
  }
end
