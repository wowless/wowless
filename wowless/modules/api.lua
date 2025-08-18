local hlist = require('wowless.hlist')

return function(
  datalua,
  env,
  events,
  log,
  loglevel,
  parentkey,
  scripts,
  templates,
  time,
  uiobjects,
  uiobjecttypes,
  visibility
)
  local frames = hlist()
  local genv = env.genv
  local secureenv = env.secureenv
  local userdata = uiobjects.userdata

  local InheritsFrom = uiobjecttypes.InheritsFrom
  local IsIntrinsicType = uiobjecttypes.IsIntrinsicType
  local IsVisible = visibility.IsVisible
  local RunScript = scripts.RunScript
  local SendEvent = events.SendEvent
  local UpdateVisible = visibility.UpdateVisible

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
    if obj.parent == parent then
      return
    end
    if obj.parent then
      local up = obj.parent
      up.children:remove(obj)
      for _, f in ipairs(parentFieldsToClear) do
        if up[f] == obj then
          up[f] = nil
        end
      end
    end
    obj.parent = parent
    if parent then
      parent.children:insert(obj)
    end
    if parent and parent.frameLevel and obj.frameLevel and not obj.hasFixedFrameLevel then
      obj:SetFrameLevel(parent.frameLevel + 1)
    end
  end

  local parentMatch = '$[pP][aA][rR][eE][nN][tT]'

  local function ParentSub(name, parent)
    if name and string.match(name, parentMatch) then
      local p = parent
      while p ~= nil and not p.name do
        p = p.parent
      end
      return string.gsub(name, parentMatch, p and p.name or 'Top')
    else
      return name
    end
  end

  local function GetDebugName(frame)
    local name = frame.name
    if name ~= nil then
      return name
    end
    name = ''
    local parent = frame.parent
    while parent do
      local key = parentkey.GetParentKey(frame) or string.match(tostring(frame), '^table: 0x0*(.*)$'):lower()
      name = key .. (name == '' and '' or ('.' .. name))
      local parentName = parent.name
      if parentName == 'UIParent' then
        break
      elseif parentName and parentName ~= '' then
        name = parentName .. '.' .. name
        break
      end
      frame = parent
      parent = parent.parent
    end
    return name
  end

  local function SetParent(obj, parent)
    if obj.shown then
      local opv = IsVisible(obj.parent)
      local npv = IsVisible(parent)
      DoSetParent(obj, parent)
      if opv ~= npv then
        UpdateVisible(obj, npv)
      end
    else
      DoSetParent(obj, parent)
    end
  end

  local function CreateUIObject(typename, objnamearg, parent, addonEnv, tmplsarg, id)
    local objname
    if type(objnamearg) == 'string' then
      objname = ParentSub(objnamearg, parent)
    elseif type(objnamearg) == 'number' then
      objname = tostring(objnamearg)
    end
    local objtype = uiobjecttypes.GetOrThrow(typename)
    log(3, 'creating %s%s', objtype.name, objname and (' named ' .. objname) or '')
    local objp = newproxy(nil)
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
      template.initEarlyAttrs(ud)
    end
    if objname then
      if type(objnamearg) == 'string' then
        objname = ParentSub(objnamearg, ud.parent)
      elseif type(objnamearg) == 'number' then
        objname = tostring(objnamearg)
      end
      ud.name = objname
      if genv[objname] then
        log(3, 'overwriting global ' .. objname)
      end
      genv[objname] = obj
      secureenv[objname] = obj
      if addonEnv then
        addonEnv[objname] = obj
      end
    end
    for _, template in ipairs(tmpls) do
      template.initAttrs(ud)
    end
    for _, template in ipairs(tmpls) do
      template.initKids(ud)
    end
    if id then
      ud:SetID(id)
    end
    if loglevel >= 3 then
      log(3, 'running load scripts on %s named %s', objtype.name, GetDebugName(ud))
    end
    RunScript(ud, 'OnLoad')
    if IsVisible(ud) then
      RunScript(ud, 'OnShow')
    end
    return ud
  end

  local function CreateFrame(type, name, parent, templateNames, id)
    local ltype = string.lower(type)
    if not IsIntrinsicType(ltype) or not InheritsFrom(ltype, 'frame') then
      if datalua.config.runtime.warners[ltype] then
        if datalua.config.runtime.send_warntype then
          SendEvent('LUA_WARNING', 0, 'Unknown frame type: ' .. type)
        else
          SendEvent('LUA_WARNING', 'Unknown frame type: ' .. type)
        end
      end
      error('CreateFrame: Unknown frame type \'' .. type .. '\'')
    end
    local tmpls = {}
    for templateName in string.gmatch(templateNames or '', '[^, ]+') do
      table.insert(tmpls, templates.GetTemplateOrThrow(templateName))
    end
    return CreateUIObject(ltype, name, parent, nil, tmpls, id)
  end

  local function NextFrame(elapsed)
    time.Advance(elapsed)
    for frame in frames:entries() do
      if IsVisible(frame) then
        RunScript(frame, 'OnUpdate', 1)
      end
    end
  end

  return {
    CreateForbiddenFrame = CreateFrame, -- TODO implement properly
    CreateFrame = CreateFrame,
    CreateUIObject = CreateUIObject,
    frames = frames,
    GetDebugName = GetDebugName,
    NextFrame = NextFrame,
    ParentSub = ParentSub,
    SetParent = SetParent,
    UserData = uiobjects.UserData,
  }
end
