local hlist = require('wowless.hlist')
return function(cstubs, datalua, log, loglevel, scripts, security)
  local allregs = hlist()
  local regs = {}
  local cbregs = {}
  local secures = {}
  for k, v in pairs(datalua.events) do
    if not v.noscript then
      regs[k] = hlist()
    end
    if v.callback then
      cbregs[k] = { frames = {}, global = hlist() }
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

  local function RegisterEventCallback(frame, event, cb)
    local uevent = event:upper()
    local cbreg = cbregs[uevent]
    if not cbreg then
      local fmt = '%s:RegisterEventCallback(): Attempt to register unknown event %q'
      local ty = frame:GetObjectType()
      error(fmt:format(ty, event), 0)
    end
    if secures[uevent] and _G.THETAINT then
      return false
    end
    cbreg.frames[frame] = cbreg.frames[frame] or hlist()
    cbreg.frames[frame]:insert(cb)
    return true
  end

  local function RegisterEventCallbackGlobal(event, cb)
    local uevent = event:upper()
    local cbreg = cbregs[uevent]
    if not cbreg then
      local fmt = 'RegisterEventCallback Attempt to register unknown event %q'
      local taint = _G.THETAINT and '\nLua Taint: ' .. _G.THETAINT or ''
      error(fmt:format(event) .. taint, 0)
    end
    if secures[uevent] and _G.THETAINT then
      return false
    end
    cbreg.global:insert(cb)
    return true
  end

  local function UnregisterEventCallbackGlobal(event, cb)
    local cbreg = assert(cbregs[event:upper()], 'cannot unregister ' .. event)
    cbreg.global:remove(cb)
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

  local echecks

  local function LoadEvents(modules)
    echecks = cstubs.loadevents(modules)
  end

  local function DoSendEvent(event, ...)
    for _, reg in ipairs(GetFramesRegisteredForEvent(event)) do
      scripts.RunScript(reg, 'OnEvent', event, ...)
    end
    local cbreg = cbregs[event]
    if cbreg then
      -- TODO unify with funtainer Invoke
      for cb in cbreg.global:entries() do
        if not cb.cancelled then
          security.CallSandbox(cb.callback, nil, ...)
        end
      end
      for frame, framecbs in pairs(cbreg.frames) do
        for cb in framecbs:entries() do
          if not cb.cancelled then
            security.CallSandbox(cb.callback, frame.luarep, ...)
          end
        end
      end
    end
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
    LoadEvents = LoadEvents,
    SendEvent = SendEvent,
    UnregisterAllEvents = UnregisterAllEvents,
    UnregisterEvent = UnregisterEvent,
    UnregisterEventCallbackGlobal = UnregisterEventCallbackGlobal,
  }
end
