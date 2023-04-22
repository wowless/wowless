local traceback = require('build.cmake.ext').traceback
local hlist = require('wowless.hlist')

local function new(log, maxErrors, product)
  local allEventRegistrations = hlist()
  local env = {}
  local errors = 0
  local eventRegistrations = {}
  local frames = hlist()
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

  local function DoSetParent(obj, parent)
    parent = parent and parent.luarep -- TODO push this down through the method
    if obj.parent == parent then
      return
    end
    if obj.parent then
      local up = u(obj.parent)
      up.children:remove(obj)
      for _, f in ipairs(parentFieldsToClear) do
        if up[f] == obj then
          up[f] = nil
        end
      end
    end
    obj.parent = parent
    if parent then
      u(parent).children:insert(obj)
    end
    if parent and u(parent).frameLevel and obj.frameLevel and not obj.hasFixedFrameLevel then
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
    if obj.scripts then
      for i = 0, 2 do
        local script = obj.scripts[i][string.lower(name)]
        if script then
          CallSafely(script, obj.luarep, ...)
        end
      end
    end
  end

  local function DoUpdateVisible(obj, script)
    for kid in obj.children:entries() do
      if kid.shown then
        DoUpdateVisible(kid, script)
      end
    end
    RunScript(obj, script)
  end

  local function UpdateVisible(obj, fn)
    local wasVisible = obj:IsVisible()
    fn()
    local visibleNow = obj:IsVisible()
    if wasVisible ~= visibleNow then
      DoUpdateVisible(obj, visibleNow and 'OnShow' or 'OnHide')
    end
  end

  local function SetParent(obj, parent)
    if obj.IsVisible then
      UpdateVisible(obj, function()
        DoSetParent(obj, parent)
      end)
    else
      DoSetParent(obj, parent)
    end
  end

  local datalua = require('build.products.' .. product .. '.data')

  local function CreateUIObject(typename, objnamearg, parent, addonEnv, tmplsarg, id)
    local objname
    if type(objnamearg) == 'string' then
      objname = ParentSub(objnamearg, parent and parent.luarep)
    elseif type(objnamearg) == 'number' then
      objname = tostring(objnamearg)
    end
    assert(typename, 'must specify type for ' .. tostring(objname))
    local objtype = uiobjectTypes[typename]
    assert(objtype, 'unknown type ' .. typename .. ' for ' .. tostring(objname))
    assert(IsIntrinsicType(typename), 'cannot create non-intrinsic type ' .. typename .. ' for ' .. tostring(objname))
    log(3, 'creating %s%s', objtype.name, objname and (' named ' .. objname) or '')
    local objp = newproxy()
    local obj = setmetatable({ [0] = objp }, objtype.sandboxMT)
    local ud = objtype.constructor()
    ud.luarep = obj
    ud.name = objname
    ud.type = typename
    userdata[objp] = ud
    setmetatable(ud, objtype.hostMT)
    DoSetParent(ud, parent)
    if InheritsFrom(typename, 'frame') then
      frames:insert(ud)
    end
    local tmpls = {}
    if objtype.template then
      table.insert(tmpls, objtype.template)
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
      if type(objnamearg) == 'string' then
        objname = ParentSub(objnamearg, ud.parent)
      elseif type(objnamearg) == 'number' then
        objname = tostring(objnamearg)
      end
      ud.name = objname
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
    RunScript(ud, 'OnLoad')
    if InheritsFrom(typename, 'region') and obj:IsVisible() then
      RunScript(ud, 'OnShow')
    end
    if objtype.zombie then
      setmetatable(obj, nil)
    end
    return obj
  end

  local function SetScript(obj, name, bindingType, script)
    obj.scripts[bindingType][string.lower(name)] = script
  end

  for k in pairs(datalua.events) do
    eventRegistrations[k] = hlist()
  end

  local function SendEvent(event, ...)
    event = event:upper()
    assert(eventRegistrations[event], 'internal error: cannot send ' .. event)
    local largs = {}
    for i = 1, select('#', ...) do
      local arg = select(i, ...)
      table.insert(largs, type(arg) == 'string' and ('%q'):format(arg) or tostring(arg))
    end
    log(1, 'sending event %s (%s)', event, table.concat(largs, ', '))
    -- Snapshot current registrations since handlers can mutate them.
    local regs = {}
    for frame in eventRegistrations[event]:entries() do
      table.insert(regs, frame)
    end
    for frame in allEventRegistrations:entries() do
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
    return CreateUIObject(ltype, name, parent and u(parent), nil, tmpls, id)
  end

  local function NextFrame(elapsed)
    local time = states.Time
    time.stamp = time.stamp + (elapsed or 1)
    while time.timers:peek().pri < time.stamp do
      local timer = time.timers:pop()
      log(2, 'running timer %.2f %s', timer.pri, tostring(timer.val))
      CallSafely(timer.val)
    end
    for frame in frames:entries() do
      if frame:IsVisible() then
        RunScript(frame, 'OnUpdate', 1)
      end
    end
  end

  local function GetErrorCount()
    return errors
  end

  local function RegisterEvent(frame, event)
    event = event:upper()
    assert(eventRegistrations[event], 'cannot register ' .. event)
    if not allEventRegistrations:has(frame) then
      eventRegistrations[event]:insert(frame)
    end
  end

  local function UnregisterEvent(frame, event)
    event = event:upper()
    assert(eventRegistrations[event], 'cannot unregister ' .. event)
    eventRegistrations[event]:remove(frame)
  end

  local function UnregisterAllEvents(frame)
    for _, reg in pairs(eventRegistrations) do
      reg:remove(frame)
    end
    allEventRegistrations:remove(frame)
  end

  local function RegisterAllEvents(frame)
    UnregisterAllEvents(frame)
    allEventRegistrations:insert(frame)
  end

  local function IsEventRegistered(frame, event)
    return allEventRegistrations:has(frame) or eventRegistrations[event:upper()]:has(frame)
  end

  for k, v in pairs(datalua.states) do
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
    uiobjects = userdata,
    uiobjectTypes = uiobjectTypes,
    UnregisterAllEvents = UnregisterAllEvents,
    UnregisterEvent = UnregisterEvent,
    UpdateVisible = UpdateVisible,
    UserData = u,
  }
  require('wowless.util').mixin(uiobjectTypes, require('wowapi.uiobjects')(api))
  return api
end

return {
  new = new,
}
