local tsort = require('resty.tsort')
local mixin = require('wowless.util').mixin

local function InheritsFrom(api, a, b)
  local result = a == b
  for _, inh in ipairs(api.uiobjectTypes[a].inherits) do
    result = result or InheritsFrom(api, inh, b)
  end
  return result
end

local function IsIntrinsicType(api, t)
  local type = api.uiobjectTypes[string.lower(t)]
  return type and type.intrinsic
end

local function IsUIObjectType(api, t)
  return api.uiobjectTypes[string.lower(t)] ~= nil
end

local function superTypes(api, type, inherits)
  local g = tsort.new()
  local function process(t)
    local ty = api.uiobjectTypes[t]
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

local function CreateUIObject(api, typename, objname, parent, inherits, xmlattr)
  assert(typename, 'must specify type for ' .. tostring(objname))
  local type = api.uiobjectTypes[typename]
  assert(type, 'unknown type ' .. typename .. ' for ' .. tostring(objname))
  api.log(3, 'creating %s%s', type.name, objname and (' named ' .. objname) or '')
  local supers = superTypes(api, typename, inherits)
  local wapi = {}
  for _, s in ipairs(supers) do
    mixin(wapi, api.uiobjectTypes[s].mixin)
  end
  local obj = setmetatable({}, {__index = wapi})
  api.userdata[obj] = {
    name = objname,
    parent = parent,
    type = typename,
  }
  for _, t in ipairs(supers) do
    local ty = api.uiobjectTypes[t]
    if ty.constructor then
      api.log(4, 'running constructor for ' .. ty.name)
      ty.constructor(obj, xmlattr or {})
    end
  end
  if objname then
    if api.env[objname] then
      api.log(1, 'overwriting global ' .. objname)
    end
    api.env[objname] = obj
  end
  return obj
end

local function CallSafely(api, fun)
  return xpcall(fun, function(err)
    api.errors = api.errors + 1
    print('error: ' .. err)
    print(debug.traceback())
  end)
end

local function RunScript(api, obj, name, ...)
  for i = 0, 2 do
    local script = obj:GetScript(name, i)
    if script then
      api.log(4, 'begin %s[%d] for %s %s', name, i, obj:GetObjectType(), tostring(obj:GetName()))
      script(obj, ...)
      api.log(4, 'end %s[%d] for %s %s', name, i, obj:GetObjectType(), tostring(obj:GetName()))
    end
  end
end

local function SetScript(api, obj, name, bindingType, script)
  api.log(4, 'setting %s[%d] for %s %s', name, bindingType, obj:GetObjectType(), tostring(obj:GetName()))
  api.userdata[obj].scripts[bindingType][string.lower(name)] = script
end

local function SendEvent(api, event, ...)
  local args = {...}
  for _, frame in ipairs(api.frames) do
    if api.userdata[frame].registeredEvents[string.lower(event)] then
      api:CallSafely(function()
        api:RunScript(frame, 'OnEvent', event, unpack(args))
      end)
    end
  end
end

local meta = {
  CallSafely = CallSafely,
  CreateUIObject = CreateUIObject,
  InheritsFrom = InheritsFrom,
  IsIntrinsicType = IsIntrinsicType,
  IsUIObjectType = IsUIObjectType,
  RunScript = RunScript,
  SendEvent = SendEvent,
  SetScript = SetScript,
}

local function new(log)
  local state = {
    env = {},
    errors = 0,
    frames = {},
    log = log,
    uiobjectTypes = {},
    userdata = {},
  }
  return setmetatable(state, {__index = meta})
end

return {
  new = new,
}
