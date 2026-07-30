local uiobject = require('wowless.uiobject')

return function(parentkey, uiobjecttypes, visibility)
  local userdata = {}
  local function UserData(obj)
    return userdata[uiobject.id(obj[0])]
  end

  local GetChildField = uiobjecttypes.GetChildField
  local GetObjectType = uiobjecttypes.GetObjectType
  local IsObjectType = uiobjecttypes.IsObjectType
  local IsVisible = visibility.IsVisible
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
    local field = GetChildField(obj.type)
    if obj.parent then
      local up = obj.parent
      up[field]:remove(obj)
      for _, f in ipairs(parentFieldsToClear) do
        if up[f] == obj then
          up[f] = nil
        end
      end
    end
    obj.parent = parent
    if parent then
      parent[field]:insert(obj)
    end
    if parent and parent.frameLevel and obj.frameLevel and not obj.hasFixedFrameLevel then
      obj:SetFrameLevel(parent.frameLevel + 1)
    end
  end

  local parentMatch = '^$[pP][aA][rR][eE][nN][tT]'

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
      local key = parentkey.GetParentKey(frame) or tostring(frame):gsub('^%S+ 0x?0*', ''):lower()
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
    if parent == nil and IsObjectType(obj, 'animation') then
      error(('%s:SetParent(): Cannot set a \'nil\' parent'):format(GetObjectType(obj)), 0)
    end
    local p = parent
    while p do
      if obj == p then
        io.stderr:write('SetParent loop, crashing\n' .. require('wowless.debug').debugstack())
        os.exit(1)
      end
      p = p.parent
    end
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

  return {
    DoSetParent = DoSetParent,
    GetDebugName = GetDebugName,
    ParentSub = ParentSub,
    SetParent = SetParent,
    userdata = userdata,
    UserData = UserData,
  }
end
