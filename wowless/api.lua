local function new(log)
  local env = {}
  local errors = 0
  local frames = {}
  local states = {}
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
    if u(obj).parent == parent then
      return
    end
    if u(obj).parent then
      u(u(obj).parent).childrenSet[obj] = nil
    end
    u(obj).parent = parent
    if parent then
      table.insert(u(parent).childrenList, obj)
      u(parent).childrenSet[obj] = #u(parent).childrenList
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
    log(0, 'error: ' .. str .. '\n' .. debug.traceback())
  end

  local function CallSafely(fun)
    return xpcall(fun, ErrorHandler)
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
      local args = { ... }
      for i = 0, 2 do
        local script = ud.scripts[i][string.lower(name)]
        if script then
          log(4, 'begin %s[%d] for %s %s', name, i, ud.type, GetDebugName(obj))
          CallSafely(function()
            script(obj, unpack(args))
          end)
          log(4, 'end %s[%d] for %s %s', name, i, ud.type, GetDebugName(obj))
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
    for _, template in ipairs({ ... }) do
      log(4, 'initializing early attributes for ' .. tostring(template.name))
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
    for _, template in ipairs({ ... }) do
      log(4, 'initializing attributes for ' .. tostring(template.name))
      template.initAttrs(obj)
    end
    for _, template in ipairs({ ... }) do
      log(4, 'initializing children for ' .. tostring(template.name))
      template.initKids(obj)
    end
    RunScript(obj, 'OnLoad')
    if InheritsFrom(typename, 'region') and obj:IsVisible() then
      RunScript(obj, 'OnShow')
    end
    return obj
  end

  local function CreateFrame(type, name, parent, templateNames)
    local ltype = string.lower(type)
    assert(IsIntrinsicType(ltype), type .. ' is not intrinsic')
    assert(InheritsFrom(ltype, 'frame'), type .. ' does not inherit from frame')
    local tmpls = {}
    for templateName in string.gmatch(templateNames or '', '[^, ]+') do
      local template = templates[string.lower(templateName)]
      assert(template, 'unknown template ' .. templateName)
      table.insert(tmpls, template)
    end
    return CreateUIObject(ltype, name, parent, nil, unpack(tmpls))
  end

  local function SetScript(obj, name, bindingType, script)
    local ud = u(obj)
    log(4, 'setting %s[%d] for %s %s', name, bindingType, ud.type, GetDebugName(obj))
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
      if frame:IsVisible() then
        RunScript(frame, 'OnUpdate', 1)
      end
    end
  end

  local function GetErrorCount()
    return errors
  end

  for _, data in pairs(require('wowapi.data').state) do
    states[data.name] = require('pl.tablex').deepcopy(data.value)
  end

  return {
    CallSafely = CallSafely,
    CreateFrame = CreateFrame,
    CreateUIObject = CreateUIObject,
    env = env,
    ErrorHandler = ErrorHandler,
    frames = frames,
    GetDebugName = GetDebugName,
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
    states = states,
    templates = templates,
    uiobjectTypes = uiobjectTypes,
    UserData = u,
  }
end

return {
  new = new,
}
