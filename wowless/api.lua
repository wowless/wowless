local function new(log)

  local tsort = require('resty.tsort')
  local mixin = require('wowless.util').mixin

  local env = {}
  local errors = 0
  local frames = {}
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
    local type = uiobjectTypes[string.lower(t)]
    return type and type.intrinsic
  end

  local function IsUIObjectType(t)
    return uiobjectTypes[string.lower(t)] ~= nil
  end

  local function superTypes(type, inherits)
    local g = tsort.new()
    local function process(t)
      local ty = uiobjectTypes[t]
      assert(ty, t .. ' is not a uiobject type')
      for _, inh in ipairs(ty.inherits or {}) do
        g:add(inh, t)
        process(inh)
      end
    end
    process(type)
    for _, inh in ipairs(inherits or {}) do
      process(inh)
    end
    return g:sort()
  end

  local function CreateUIObject(typename, objname, parent, inherits, xmlattr)
    assert(typename, 'must specify type for ' .. tostring(objname))
    local type = uiobjectTypes[typename]
    assert(type, 'unknown type ' .. typename .. ' for ' .. tostring(objname))
    log(3, 'creating %s%s', type.name, objname and (' named ' .. objname) or '')
    local supers = superTypes(typename, inherits)
    local wapi = {}
    for _, s in ipairs(supers) do
      mixin(wapi, uiobjectTypes[s].mixin)
    end
    local obj = setmetatable({}, {__index = wapi})
    userdata[obj] = {
      name = objname,
      parent = parent,
      type = typename,
    }
    for _, t in ipairs(supers) do
      local ty = uiobjectTypes[t]
      if ty.constructor then
        log(4, 'running constructor for ' .. ty.name)
        ty.constructor(obj, xmlattr or {})
      end
    end
    if objname then
      if env[objname] then
        log(1, 'overwriting global ' .. objname)
      end
      env[objname] = obj
    end
    return obj
  end

  local function CallSafely(fun)
    return xpcall(fun, function(err)
      errors = errors + 1
      print('error: ' .. err)
      print(debug.traceback())
    end)
  end

  local function RunScript(obj, name, ...)
    for i = 0, 2 do
      local script = obj:GetScript(name, i)
      if script then
        log(4, 'begin %s[%d] for %s %s', name, i, obj:GetObjectType(), tostring(obj:GetName()))
        script(obj, ...)
        log(4, 'end %s[%d] for %s %s', name, i, obj:GetObjectType(), tostring(obj:GetName()))
      end
    end
  end

  local function SetScript(obj, name, bindingType, script)
    log(4, 'setting %s[%d] for %s %s', name, bindingType, obj:GetObjectType(), tostring(obj:GetName()))
    userdata[obj].scripts[bindingType][string.lower(name)] = script
  end

  local function SendEvent(event, ...)
    local args = {...}
    for _, frame in ipairs(frames) do
      if userdata[frame].registeredEvents[string.lower(event)] then
        CallSafely(function()
          RunScript(frame, 'OnEvent', event, unpack(args))
        end)
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
    IsUIObjectType = IsUIObjectType,
    log = log,
    RunScript = RunScript,
    SendEvent = SendEvent,
    SetScript = SetScript,
    uiobjectTypes = uiobjectTypes,
    UserData = UserData,
  }
end

return {
  new = new,
}
