local function new(log)

  local env = {}
  local errors = 0
  local frames = {}
  local templates = {}
  local uiobjectTypes = {}
  local userdata = {}

  local function InheritsFrom(a, b)
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
    if userdata[obj].parent then
      userdata[userdata[obj].parent].children[obj] = nil
    end
    userdata[obj].parent = parent
    if parent then
      userdata[parent].children[obj] = true
    end
  end

  local function ParentSub(name, parent)
    if name and string.match(name, '$parent') then
      local p = parent
      while p ~= nil and not userdata[p].name do
        p = userdata[p].parent
      end
      return string.gsub(name, '$parent', p and userdata[p].name or 'Top')
    else
      return name
    end
  end

  local function CallSafely(fun)
    return xpcall(fun, function(err)
      errors = errors + 1
      log(0, 'error: ' .. err .. '\n' .. debug.traceback())
    end)
  end

  local function RunScript(obj, name, ...)
    if obj.GetScript then
      local args = {...}
      for i = 0, 2 do
        local script = obj:GetScript(name, i)
        if script then
          log(4, 'begin %s[%d] for %s %s', name, i, obj:GetObjectType(), tostring(obj:GetName()))
          CallSafely(function() script(obj, unpack(args)) end)
          log(4, 'end %s[%d] for %s %s', name, i, obj:GetObjectType(), tostring(obj:GetName()))
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
    userdata[obj] = {
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
      objname = ParentSub(objnamearg, userdata[obj].parent)
      userdata[obj].name = objname
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
    if userdata[obj].visible then
      RunScript(obj, 'OnShow')
    end
    return obj
  end

  local function SetScript(obj, name, bindingType, script)
    log(4, 'setting %s[%d] for %s %s', name, bindingType, obj:GetObjectType(), tostring(obj:GetName()))
    userdata[obj].scripts[bindingType][string.lower(name)] = script
  end

  local function SendEvent(event, ...)
    for _, frame in ipairs(frames) do
      if userdata[frame].registeredEvents[string.lower(event)] then
        RunScript(frame, 'OnEvent', event, ...)
      end
    end
  end

  local function NextFrame()
    for _, frame in ipairs(frames) do
      if userdata[frame].visible then
        RunScript(frame, 'OnUpdate', 1)
      end
    end
  end

  local function GetErrorCount()
    return errors
  end

  local function UserData(obj)
    return userdata[obj]
  end

  return {
    CallSafely = CallSafely,
    CreateUIObject = CreateUIObject,
    env = env,
    frames = frames,
    GetErrorCount = GetErrorCount,
    InheritsFrom = InheritsFrom,
    IsIntrinsicType = IsIntrinsicType,
    log = log,
    NextFrame = NextFrame,
    ParentSub = ParentSub,
    RunScript = RunScript,
    SendEvent = SendEvent,
    SetParent = SetParent,
    SetScript = SetScript,
    templates = templates,
    uiobjectTypes = uiobjectTypes,
    UserData = UserData,
  }
end

return {
  new = new,
}
