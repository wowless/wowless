return function(datalua, events, intrinsics, templates, uiobjecttypes)
  local GetIntrinsic = intrinsics.Get
  local HasType = uiobjecttypes.Has
  local InheritsFrom = uiobjecttypes.InheritsFrom
  local SendEvent = events.SendEvent

  local function CreateFrame(type, name, parent, templateNames, id)
    local ltype = string.lower(type)
    local intrinsicEntry = GetIntrinsic(ltype)
    local basetype = intrinsicEntry and intrinsicEntry.basetype or ltype
    if not HasType(basetype) or not InheritsFrom(basetype, 'frame') then
      if datalua.config.runtime.warners[ltype] then
        SendEvent('LUA_WARNING', 'Unknown frame type: ' .. type)
      end
      error('CreateFrame: Unknown frame type \'' .. type .. '\'', 0)
    end
    local tmpls = {}
    if intrinsicEntry then
      table.insert(tmpls, intrinsicEntry.template)
    end
    for templateName in string.gmatch(templateNames or '', '[^, ]+') do
      table.insert(tmpls, templates.GetTemplateOrThrow(templateName))
    end
    return templates.CreateUIObject(basetype, name, parent, nil, tmpls, id)
  end

  local function CreateChildUIObject(typename, self, name, inherits, layer, sublevel)
    local tmpls = {}
    for templateName in string.gmatch(inherits or '', '[^, ]+') do
      table.insert(tmpls, templates.GetTemplateOrThrow(templateName))
    end
    return templates.CreateUIObject(typename, name, self, nil, tmpls, nil, layer, sublevel)
  end

  return {
    CreateChildUIObject = CreateChildUIObject,
    CreateForbiddenFrame = CreateFrame, -- TODO implement properly
    CreateFrame = CreateFrame,
  }
end
