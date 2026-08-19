return function(datalua, eventqueue, intrinsics, templates, uiobjecttypes, xmleval)
  local GetIntrinsic = intrinsics.Get
  local HasType = uiobjecttypes.Has
  local InheritsFrom = uiobjecttypes.InheritsFrom
  local QueueEvent = eventqueue.QueueEvent

  local function CreateFrame(type, name, parent, templateNames, id)
    local ltype = string.lower(type)
    local intrinsicEntry = GetIntrinsic(ltype)
    local basetype = intrinsicEntry and intrinsicEntry.basetype or ltype
    -- issue #116: an intrinsic of an intrinsic parses fine but a real client
    -- refuses to instantiate it, the same way it does an unknown frame type.
    local nested = intrinsicEntry and intrinsicEntry.nested
    if nested or not HasType(basetype) or not InheritsFrom(basetype, 'frame') then
      if nested or datalua.config.runtime.warners[ltype] then
        QueueEvent('LUA_WARNING', 'Unknown frame type: ' .. type)
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
    return xmleval.CreateUIObject(basetype, name, parent, nil, tmpls, id)
  end

  local function CreateChildUIObject(typename, self, name, inherits, layer, sublevel)
    local tmpls = inherits and { templates.GetTemplateOrThrow(inherits) }
    return xmleval.CreateUIObject(typename, name, self, nil, tmpls, nil, layer, sublevel)
  end

  return {
    CreateChildUIObject = CreateChildUIObject,
    CreateForbiddenFrame = CreateFrame, -- TODO implement properly
    CreateFrame = CreateFrame,
  }
end
