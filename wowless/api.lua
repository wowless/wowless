local function new(log)

  local env = {}
  local errors = 0
  local frames = {}
  local templates = {}
  local uiobjectTypes = {}
  local userdata = {}

  local function u(obj)
    return userdata[obj[0]]
  end

  local function InheritsFrom(a, b)
    assert(uiobjectTypes[a], 'unknown type ' .. a)
    local result = a == b
    for _, inh in ipairs(uiobjectTypes[a].inherits) do
      result = result or InheritsFrom(inh, b)
    end
    return result
  end

  local function IsIntrinsicType(t)
    return uiobjectTypes[string.lower(t)] ~= nil
  end

  local function SetParent(obj, parent)
    if u(obj).parent then
      u(u(obj).parent).children[obj] = nil
    end
    u(obj).parent = parent
    if parent then
      u(parent).children[obj] = true
    end
  end

  local function ParentSub(name, parent)
    if name and string.match(name, '$parent') then
      local p = parent
      while p ~= nil and not u(p).name do
        p = u(p).parent
      end
      return string.gsub(name, '$parent', p and u(p).name or 'Top')
    else
      return name
    end
  end

  local function ErrorHandler(str)
    errors = errors + 1
    log(0, 'error: ' .. str .. '\n' .. debug.traceback())
  end

  local function CallSafely(fun)
    return xpcall(fun, ErrorHandler)
  end

  local function RunScript(obj, name, ...)
    local ud = u(obj)
    if ud.scripts then
      local args = {...}
      for i = 0, 2 do
        local script = ud.scripts[i][string.lower(name)]
        if script then
          log(4, 'begin %s[%d] for %s %s', name, i, ud.type, tostring(ud.name))
          CallSafely(function() script(obj, unpack(args)) end)
          log(4, 'end %s[%d] for %s %s', name, i, ud.type, tostring(ud.name))
        end
      end
    end
  end

  local function CreateUIObject(typename, objnamearg, parent, addonEnv, ...)
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
    SetParent(obj, parent)
    type.constructor(obj)
    for _, template in ipairs({...}) do
      log(4, 'initializing attributes for ' .. tostring(template.name))
      template.initAttrs(obj)
    end
    if objname then
      objname = ParentSub(objnamearg, u(obj).parent)
      u(obj).name = objname
      if env[objname] then
        log(1, 'overwriting global ' .. objname)
      end
      env[objname] = obj
      if addonEnv then
        addonEnv[objname] = obj
      end
    end
    for _, template in ipairs({...}) do
      log(4, 'initializing children for ' .. tostring(template.name))
      template.initKids(obj)
    end
    RunScript(obj, 'OnLoad')
    if u(obj).visible then
      RunScript(obj, 'OnShow')
    end
    return obj
  end

  local function SetScript(obj, name, bindingType, script)
    local ud = u(obj)
    log(4, 'setting %s[%d] for %s %s', name, bindingType, ud.type, tostring(ud.name))
    ud.scripts[bindingType][string.lower(name)] = script
  end

  local function SendEvent(event, ...)
    log(1, 'sending event %s', event)
    local ev = string.lower(event)
    for _, frame in ipairs(frames) do
      local ud = u(frame)
      if ud.registeredEvents[ev] or ud.registeredAllEvents then
        RunScript(frame, 'OnEvent', event, ...)
      end
    end
  end

  local function NextFrame()
    for _, frame in ipairs(frames) do
      if u(frame).visible then
        RunScript(frame, 'OnUpdate', 1)
      end
    end
  end

  local function GetErrorCount()
    return errors
  end

  return {
    CallSafely = CallSafely,
    CreateUIObject = CreateUIObject,
    env = env,
    ErrorHandler = ErrorHandler,
    frames = frames,
    GetErrorCount = GetErrorCount,
    InheritsFrom = InheritsFrom,
    IsIntrinsicType = IsIntrinsicType,
    isLoggedIn = false,
    log = log,
    NextFrame = NextFrame,
    ParentSub = ParentSub,
    RunScript = RunScript,
    SendEvent = SendEvent,
    SetParent = SetParent,
    SetScript = SetScript,
    templates = templates,
    uiobjectTypes = uiobjectTypes,
    UserData = u,
  }
end

return {
  new = new,
}
