(function(self)
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
end)(...)
