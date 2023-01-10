local traceback = require('wowless.ext').traceback

local function new(log, maxErrors, product)
  local allEventRegistrations = {}
  local env = {}
  local errors = 0
  local eventRegistrations = {}
  local frames = {}
  local states = {}
  local templates = {}
  local uiobjectTypes = {}
  local userdata = {}

  local function u(obj)
    return userdata[obj[0]]
  end

  local function InheritsFrom(a, b)
    local t = uiobjectTypes[a]
    assert(t, 'unknown type ' .. a)
    return t.isa[b]
  end

  local function IsIntrinsicType(t)
    return uiobjectTypes[string.lower(t)] ~= nil
  end

  local parentFieldsToClear = {
    'disabledTexture',
    'fontstring',
    'highlightTexture',
    'normalTexture',
    'pushedTexture',
    'scrollChild',
    'statusBarTexture',
  }

  local function SetParent(obj, parent)
    if u(obj).parent == parent then
      return
    end
    if u(obj).parent then
      local up = u(u(obj).parent)
      up.childrenSet[obj] = nil
      for _, f in ipairs(parentFieldsToClear) do
        if up[f] == obj then
          up[f] = nil
        end
      end
    end
    u(obj).parent = parent
    if parent then
      table.insert(u(parent).childrenList, obj)
      u(parent).childrenSet[obj] = #u(parent).childrenList
    end
    if parent and u(parent).frameLevel and u(obj).frameLevel and not u(obj).hasFixedFrameLevel then
      obj:SetFrameLevel(u(parent).frameLevel + 1)
    end
  end

  local parentMatch = '$[pP][aA][rR][eE][nN][tT]'

  local function ParentSub(name, parent)
    if name and string.match(name, parentMatch) then
      local p = parent
      while p ~= nil and not u(p).name do
        p = u(p).parent
      end
      return string.gsub(name, parentMatch, p and u(p).name or 'Top')
    else
      return name
    end
  end

  local function ErrorHandler(str)
    errors = errors + 1
    log(0, 'error: ' .. str .. '\n' .. traceback())
    if maxErrors and errors >= maxErrors then
      log(0, 'maxerrors reached, quitting')
      os.exit(0)
    end
  end

  local function CallSafely(fun, ...)
    return xpcall(fun, ErrorHandler, ...)
  end

  local function GetDebugName(frame)
    local ud = u(frame)
    local name = ud.name
    if name ~= nil then
      return name
    end
    name = ''
    local parent = ud.parent
    local pud
    while parent do
      pud = u(parent)
      local found = false
      for k, v in pairs(parent) do
        if v == frame then
          name = k .. (name == '' and '' or ('.' .. name))
          found = true
        end
      end
      if not found then
        name = string.match(tostring(frame), '^table: 0x0*(.*)$'):lower() .. (name == '' and '' or ('.' .. name))
      end
      local parentName = pud.name
      if parentName == 'UIParent' then
        break
      elseif parentName and parentName ~= '' then
        name = parentName .. '.' .. name
        break
      end
      frame = parent
      parent = pud.parent
    end
    return name
  end

  local function RunScript(obj, name, ...)
    local ud = u(obj)
    if ud.scripts then
      for i = 0, 2 do
        local script = ud.scripts[i][string.lower(name)]
        if script then
          CallSafely(function(...)
            script(obj, ...)
          end, ...)
        end
      end
    end
  end

  local datalua = require('build.products.' .. product .. '.data')

  local function CreateUIObject(typename, objnamearg, parent, addonEnv, tmplsarg, id)
    local objname = ParentSub(objnamearg, parent)
    assert(typename, 'must specify type for ' .. tostring(objname))
    local type = uiobjectTypes[typename]
    assert(type, 'unknown type ' .. typename .. ' for ' .. tostring(objname))
    assert(IsIntrinsicType(typename), 'cannot create non-intrinsic type ' .. typename .. ' for ' .. tostring(objname))
    log(3, 'creating %s%s', type.name, objname and (' named ' .. objname) or '')
    local obj = setmetatable({}, type.metatable)
    obj[0] = newproxy()
    userdata[obj[0]] = {
      name = objname,
      type = typename,
    }
    type.constructor(obj)
    SetParent(obj, parent)
    if InheritsFrom(typename, 'frame') then
      table.insert(frames, obj)
      u(obj).frameIndex = #frames
    end
    local tmpls = {}
    if type.template then
      table.insert(tmpls, type.template)
    end
    if tmplsarg then
      for _, tmpl in ipairs(tmplsarg) do
        table.insert(tmpls, tmpl)
      end
    end
    for _, template in ipairs(tmpls) do
      template.initEarlyAttrs(obj)
    end
    if objname then
      objname = ParentSub(objnamearg, u(obj).parent)
      u(obj).name = objname
      if env[objname] then
        log(3, 'overwriting global ' .. objname)
      end
      env[objname] = obj
      if addonEnv then
        addonEnv[objname] = obj
      end
    end
    for _, template in ipairs(tmpls) do
      template.initAttrs(obj)
    end
    for _, template in ipairs(tmpls) do
      template.initKids(obj)
    end
    if id then
      obj:SetID(id)
    end
    RunScript(obj, 'OnLoad')
    if InheritsFrom(typename, 'region') and obj:IsVisible() then
      RunScript(obj, 'OnShow')
    end
    -- I have found a theory for this hack but this comment is too small to contain it.
    if typename == 'fogofwarframe' and datalua.build.flavor ~= 'Mainline' then
      setmetatable(obj, nil)
    end
    return obj
  end

  local function SetScript(obj, name, bindingType, script)
    local ud = u(obj)
    ud.scripts[bindingType][string.lower(name)] = script
  end

  local function SendEvent(event, ...)
    local largs = {}
    for i = 1, select('#', ...) do
      local arg = select(i, ...)
      table.insert(largs, type(arg) == 'string' and ('%q'):format(arg) or tostring(arg))
    end
    event = event:upper()
    log(1, 'sending event %s (%s)', event, table.concat(largs, ', '))
    -- Snapshot current registrations since handlers can mutate them.
    local regs = {}
    for i, frame in ipairs(eventRegistrations[event] or {}) do
      assert(u(frame).registeredEvents[event] == i, 'event registration invariant violated')
      table.insert(regs, frame)
    end
    for i, frame in ipairs(allEventRegistrations) do
      assert(u(frame).registeredAllEvents == i, 'event registration invariant violated')
      table.insert(regs, frame)
    end
    for _, reg in ipairs(regs) do
      RunScript(reg, 'OnEvent', event, ...)
    end
  end

  local function CreateFrame(type, name, parent, templateNames, id)
    local ltype = string.lower(type)
    if not IsIntrinsicType(ltype) or not InheritsFrom(ltype, 'frame') then
      if not uiobjectTypes[ltype] or ltype == 'texture' or ltype == 'line' or ltype == 'fontstring' then
        SendEvent('LUA_WARNING', 0, 'Unknown frame type: ' .. type)
      end
      error('CreateFrame: Unknown frame type \'' .. type .. '\'')
    end
    local tmpls = {}
    for templateName in string.gmatch(templateNames or '', '[^, ]+') do
      local template = templates[string.lower(templateName)]
      assert(template, 'unknown template ' .. templateName)
      table.insert(tmpls, template)
    end
    return CreateUIObject(ltype, name, parent, nil, tmpls, id)
  end

  local function NextFrame(elapsed)
    local time = states.Time
    time.stamp = time.stamp + (elapsed or 1)
    while time.timers:peek().pri < time.stamp do
      local timer = time.timers:pop()
      log(2, 'running timer %.2f %s', timer.pri, tostring(timer.val))
      CallSafely(timer.val)
    end
    for _, frame in ipairs(frames) do
      if frame.IsVisible and frame:IsVisible() then
        RunScript(frame, 'OnUpdate', 1)
      end
    end
  end

  local function GetErrorCount()
    return errors
  end

  local eventConfigs = datalua.events

  local function RegisterEvent(frame, event)
    event = event:upper()
    assert(eventConfigs[event], 'cannot register ' .. event)
    local ud = u(frame)
    if not ud.registeredEvents[event] and not ud.registeredAllEvents then
      local reg = eventRegistrations[event]
      if not reg then
        reg = {}
        eventRegistrations[event] = reg
      end
      table.insert(reg, frame)
      ud.registeredEvents[event] = #reg
    end
  end

  local function UnregisterEvent(frame, event)
    event = event:upper()
    local ud = u(frame)
    local idx = ud.registeredEvents[event]
    if idx then
      local reg = eventRegistrations[event]
      assert(reg and reg[idx] == frame, 'event registration invariant violated')
      if idx ~= #reg then
        reg[idx] = reg[#reg]
        u(reg[idx]).registeredEvents[event] = idx
      end
      reg[#reg] = nil
      ud.registeredEvents[event] = nil
    end
  end

  local function UnregisterAllEvents(frame)
    local ud = u(frame)
    for k in pairs(ud.registeredEvents) do
      UnregisterEvent(frame, k)
    end
    local idx = ud.registeredAllEvents
    if idx then
      assert(allEventRegistrations[idx] == frame, 'event registration invariant violated')
      if idx ~= #allEventRegistrations then
        allEventRegistrations[idx] = allEventRegistrations[#allEventRegistrations]
        u(allEventRegistrations[idx]).registeredAllEvents = idx
      end
      allEventRegistrations[#allEventRegistrations] = nil
      ud.registeredAllEvents = nil
    end
  end

  local function RegisterAllEvents(frame)
    UnregisterAllEvents(frame)
    table.insert(allEventRegistrations, frame)
    u(frame).registeredAllEvents = #allEventRegistrations
  end

  local function IsEventRegistered(frame, event)
    event = event:upper()
    local ud = u(frame)
    return ud.registeredAllEvents or ud.registeredEvents[event]
  end

  for k, v in pairs(datalua.state) do
    states[k] = require('pl.tablex').deepcopy(v)
  end
  seterrorhandler(ErrorHandler)

  local api = {
    CallSafely = CallSafely,
    CreateFrame = CreateFrame,
    CreateUIObject = CreateUIObject,
    datalua = datalua,
    env = env,
    ErrorHandler = ErrorHandler,
    frames = frames,
    GetDebugName = GetDebugName,
    GetErrorCount = GetErrorCount,
    InheritsFrom = InheritsFrom,
    IsEventRegistered = IsEventRegistered,
    IsIntrinsicType = IsIntrinsicType,
    log = log,
    NextFrame = NextFrame,
    ParentSub = ParentSub,
    product = product,
    RegisterAllEvents = RegisterAllEvents,
    RegisterEvent = RegisterEvent,
    RunScript = RunScript,
    SendEvent = SendEvent,
    SetParent = SetParent,
    SetScript = SetScript,
    states = states,
    templates = templates,
    uiobjectTypes = uiobjectTypes,
    UnregisterAllEvents = UnregisterAllEvents,
    UnregisterEvent = UnregisterEvent,
    UserData = u,
  }
  require('wowless.util').mixin(uiobjectTypes, require('wowapi.uiobjects')(api))
  return api
end

return {
  new = new,
}
