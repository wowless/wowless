return {
  constructor = function(self)
    local ud = u(self)
    ud.alpha = 1
    ud.animationGroups = {}
    ud.bottom = 0
    ud.explicitlyProtected = false
    ud.height = 0
    ud.isIgnoringParentAlpha = false
    ud.isIgnoringParentScale = false
    ud.left = 0
    ud.points = {}
    ud.protected = false
    ud.scale = 1
    ud.shown = true
    ud.visible = not ud.parent or u(ud.parent).visible
    ud.width = 0
  end,
  inherits = {'ParentedObject'},
  mixin = {
    AdjustPointsOffset = UNIMPLEMENTED,
    ClearAllPoints = function(self)
      util.twipe(u(self).points)
    end,
    CreateAnimationGroup = function(self)
      local group = api.CreateUIObject('animationgroup')
      table.insert(u(self).animationGroups, group)
      return group
    end,
    GetAlpha = function(self)
      return u(self).alpha
    end,
    GetAnimationGroups = function(self)
      return unpack(u(self).animationGroups)
    end,
    GetBottom = function(self)
      return u(self).bottom
    end,
    GetCenter = function()
      return 1, 1  -- UNIMPLEMENTED
    end,
    GetEffectiveAlpha = function(self)
      local ud = u(self)
      if not ud.parent or ud.isIgnoringParentAlpha then
        return ud.alpha
      else
        return m(ud.parent, 'GetEffectiveAlpha') * ud.alpha
      end
    end,
    GetEffectiveScale = function(self)
      local ud = u(self)
      if not ud.parent or ud.isIgnoringParentScale then
        return ud.scale
      else
        return m(ud.parent, 'GetEffectiveScale') * ud.scale
      end
    end,
    GetHeight = function(self)
      return u(self).height
    end,
    GetLeft = function(self)
      return u(self).left
    end,
    GetNumPoints = function(self)
      return #u(self).points
    end,
    GetPoint = function(self, index)
      local idx
      if type(index) == 'string' then
        local i = 1
        while not idx and i <= #u(self).points do
          if u(self).points[i][1] == index then
            idx = i
          end
          i = i + 1
        end
      else
        idx = index or 1
      end
      if u(self).points[idx] then
        assert(type(u(self).points[idx][4]) ~= 'table')
        return unpack(u(self).points[idx])
      else
        api.log(1, 'returning fake point')
        return 'CENTER', api.env.UIParent, 'CENTER', 0, 0
      end
    end,
    GetRect = function(self)
      local ud = u(self)
      return ud.bottom, ud.left, ud.width, ud.height
    end,
    GetRight = function(self)
      return u(self).left + u(self).width
    end,
    GetScale = function(self)
      return u(self).scale
    end,
    GetScaledRect = function(self)
      local s = m(self, 'GetEffectiveScale')
      local b, l, w, h = m(self, 'GetRect')
      return b * s, l * s, w * s, h * s
    end,
    GetSize = function(self)
      return m(self, 'GetWidth'), m(self, 'GetHeight')
    end,
    GetTop = function(self)
      return u(self).bottom + u(self).height
    end,
    GetWidth = function(self)
      return u(self).width
    end,
    Hide = function(self)
      m(self, 'SetShown', false)
    end,
    IsIgnoringParentAlpha = function(self)
      return u(self).isIgnoringParentAlpha
    end,
    IsIgnoringParentScale = function(self)
      return u(self).isIgnoringParentScale
    end,
    IsMouseOver = UNIMPLEMENTED,
    IsProtected = function(self)
      return u(self).protected, u(self).explicitlyProtected
    end,
    IsShown = function(self)
      return u(self).shown
    end,
    IsVisible = function(self)
      return u(self).visible
    end,
    SetAllPoints = UNIMPLEMENTED,
    SetAlpha = function(self, alpha)
      u(self).alpha = alpha < 0 and 0 or alpha > 1 and 1 or alpha
    end,
    SetHeight = function(self, height)
      u(self).height = height
    end,
    SetIgnoreParentAlpha = function(self, ignore)
      u(self).isIgnoringParentAlpha = not not ignore
    end,
    SetParent = function(self, parent)
      if type(parent) == 'string' then
        parent = api.env[parent]
      end
      api.SetParent(self, parent)
      UpdateVisible(self)
    end,
    SetPoint = function(self, arg1, arg2, arg3, arg4, arg5)
      -- TODO handle resetting points
      local point = arg1 or 'CENTER'
      local relativeTo = u(self).parent
      local relativePoint = 'CENTER'
      local x = 0
      local y = 0
      if type(arg2) == 'number' and type(arg3) == 'number' then
        x = arg2
        y = arg3
      else
        if type(arg2) == 'string' then
          local name = api.ParentSub(arg2, relativeTo)
          local frame = api.env[name]
          if not frame then
            api.log(1, 'SetPoint to unknown frame %q', name)
          end
          relativeTo = frame
        elseif type(arg2) == 'table' then
          relativeTo = arg2
        else
          assert(arg2 == nil)
        end
        if type(arg3) == 'number' and type(arg4) == 'number' then
          -- This is speculative based on usage in FrameXML.
          x = arg3
          y = arg4
        elseif type(arg3) == 'string' then
          relativePoint = arg3
          if type(arg4) == 'number' and type(arg5) == 'number' then
            x = arg4
            y = arg5
          end
        end
      end
      table.insert(u(self).points, { point, relativeTo, relativePoint, x, y })
    end,
    SetScale = function(self, scale)
      if scale > 0 then
        u(self).scale = scale
      end
    end,
    SetShown = function(self, shown)
      u(self).shown = shown
      UpdateVisible(self)
    end,
    SetSize = UNIMPLEMENTED,
    SetWidth = function(self, width)
      u(self).width = width
    end,
    Show = function(self)
      m(self, 'SetShown', true)
    end,
  },
}
