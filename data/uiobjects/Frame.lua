return {
  constructor = function(self)
    table.insert(api.frames, self)
    u(self).attributes = {}
    u(self).frameIndex = #api.frames
    u(self).frameLevel = 1
    u(self).frameStrata = 'MEDIUM'
    u(self).hyperlinksEnabled = false
    u(self).id = 0
    u(self).isClampedToScreen = false
    u(self).isUserPlaced = false
    u(self).mouseClickEnabled = true
    u(self).mouseMotionEnabled = true
    u(self).mouseWheelEnabled = false
    u(self).movable = false
    u(self).registeredAllEvents = false
    u(self).registeredEvents = {}
    u(self).resizable = false
    u(self).toplevel = false
  end,
  inherits = {'ParentedObject', 'Region', 'ScriptObject'},
  mixin = {
    CreateFontString = function(self, name)
      return api.CreateUIObject('fontstring', name, self)
    end,
    CreateMaskTexture = function(self)
      return api.CreateUIObject('masktexture', nil, self)
    end,
    CreateTexture = function(self, name)
      return api.CreateUIObject('texture', name, self)
    end,
    DesaturateHierarchy = UNIMPLEMENTED,
    DisableDrawLayer = UNIMPLEMENTED,
    EnableKeyboard = UNIMPLEMENTED,
    EnableMouse = function(self, value)
      local ud = u(self)
      ud.mouseClickEnabled = not not value
      ud.mouseMotionEnabled = not not value
    end,
    EnableMouseWheel = function(self, value)
      u(self).mouseWheelEnabled = not not value
    end,
    GetAttribute = function(self, arg1, arg2, arg3)
      local attrs = u(self).attributes
      if arg3 then
        local keys = {
          arg1 .. arg2 .. arg3,
          '*' .. arg2 .. arg3,
          arg1 .. arg2 .. '*',
          '*' .. arg2 .. '*',
          arg2,
        }
        for _, k in ipairs(keys) do
          if attrs[k] then
            return attrs[k]
          end
        end
        return nil
      else
        return attrs[arg1]
      end
    end,
    GetChildren = function(self)
      local ret = {}
      for kid in kids(self) do
        if api.InheritsFrom(u(kid).type, 'frame') then
          table.insert(ret, kid)
        end
      end
      return unpack(ret)
    end,
    GetFrameLevel = function(self)
      return u(self).frameLevel
    end,
    GetFrameStrata = function(self)
      return u(self).frameStrata
    end,
    GetHyperlinksEnabled = function(self)
      return u(self).hyperlinksEnabled
    end,
    GetID = function(self)
      return u(self).id
    end,
    GetMaxResize = function(self)
      return u(self).maxResizeWidth, u(self).maxResizeHeight
    end,
    GetMinResize = function(self)
      return u(self).minResizeWidth, u(self).minResizeHeight
    end,
    GetNumChildren = function(self)
      return select('#', m(self, 'GetChildren'))
    end,
    GetNumRegions = function(self)
      return select('#', m(self, 'GetRegions'))
    end,
    GetRegions = function(self)
      local ret = {}
      for kid in kids(self) do
        if api.InheritsFrom(u(kid).type, 'layeredregion') then
          table.insert(ret, kid)
        end
      end
      return unpack(ret)
    end,
    IgnoreDepth = UNIMPLEMENTED,
    IsClampedToScreen = function(self)
      return u(self).isClampedToScreen
    end,
    IsEventRegistered = function(self, event)
      local ud = u(self)
      return ud.registeredAllEvents or not not ud.registeredEvents[string.lower(event)]
    end,
    IsMouseClickEnabled = function(self)
      return u(self).mouseClickEnabled
    end,
    IsMouseEnabled = function(self)
      local ud = u(self)
      return ud.mouseClickEnabled and ud.mouseMotionEnabled
    end,
    IsMouseMotionEnabled = function(self)
      return u(self).mouseMotionEnabled
    end,
    IsMouseWheelEnabled = function(self)
      return u(self).mouseWheelEnabled
    end,
    IsMovable = function(self)
      return u(self).movable
    end,
    IsResizable = function(self)
      return u(self).resizable
    end,
    IsToplevel = function(self)
      return u(self).toplevel
    end,
    IsUserPlaced = function(self)
      return u(self).isUserPlaced
    end,
    Raise = UNIMPLEMENTED,
    RegisterAllEvents = function(self)
      u(self).registeredAllEvents = true
    end,
    RegisterEvent = function(self, event)
      u(self).registeredEvents[string.lower(event)] = true
    end,
    RegisterForDrag = UNIMPLEMENTED,
    RegisterForMouse = UNIMPLEMENTED,
    RegisterUnitEvent = function(self, event)  -- unit1, unit2
      -- TODO actually do unit filtering
      u(self).registeredEvents[string.lower(event)] = true
    end,
    SetAttribute = function(self, name, value)
      api.log(4, 'setting attribute %s on %s to %s', name, tostring(self:GetName()), tostring(value))
      u(self).attributes[name] = value
      api.RunScript(self, 'OnAttributeChanged', name, value)
    end,
    SetBackdrop = loader.version == 'Vanilla' and UNIMPLEMENTED or nil,
    SetBackdropBorderColor = loader.version == 'Vanilla' and UNIMPLEMENTED or nil,
    SetBackdropColor = loader.version == 'Vanilla' and UNIMPLEMENTED or nil,
    SetClampedToScreen = function(self, value)
      u(self).isClampedToScreen = not not value
    end,
    SetClampRectInsets = UNIMPLEMENTED,
    SetClipsChildren = UNIMPLEMENTED,
    SetDepth = UNIMPLEMENTED,
    SetDontSavePosition = UNIMPLEMENTED,
    SetFixedFrameLevel = loader.version ~= 'Vanilla' and UNIMPLEMENTED or nil,
    SetFixedFrameStrata = loader.version ~= 'Vanilla' and UNIMPLEMENTED or nil,
    SetFrameLevel = function(self, frameLevel)
      u(self).frameLevel = frameLevel
    end,
    SetFrameStrata = function(self, frameStrata)
      u(self).frameStrata = frameStrata
    end,
    SetHitRectInsets = UNIMPLEMENTED,
    SetHyperlinksEnabled = function(self, value)
      u(self).hyperlinksEnabled = not not value
    end,
    SetID = function(self, id)
      assert(type(id) == 'number', 'invalid ID ' .. tostring(id))
      u(self).id = id
    end,
    SetMaxResize = function(self, maxWidth, maxHeight)
      u(self).maxResizeWidth = maxWidth
      u(self).maxResizeHeight = maxHeight
    end,
    SetMinResize = function(self, minWidth, minHeight)
      u(self).minResizeWidth = minWidth
      u(self).minResizeHeight = minHeight
    end,
    SetMouseClickEnabled = function(self, value)
      u(self).mouseClickEnabled = not not value
    end,
    SetMouseMotionEnabled = function(self, value)
      u(self).mouseMotionEnabled = not not value
    end,
    SetMovable = function(self, value)
      u(self).movable = not not value
    end,
    SetResizable = function(self, value)
      u(self).resizable = not not value
    end,
    SetToplevel = function(self, value)
      u(self).toplevel = not not value
    end,
    SetUserPlaced = function(self, value)
      u(self).isUserPlaced = not not value
    end,
    StartMoving = UNIMPLEMENTED,
    StopMovingOrSizing = UNIMPLEMENTED,
    UnregisterAllEvents = function(self)
      u(self).registeredAllEvents = false
      util.twipe(u(self).registeredEvents)
    end,
    UnregisterEvent = function(self, event)
      u(self).registeredEvents[string.lower(event)] = nil
    end,
  },
}
