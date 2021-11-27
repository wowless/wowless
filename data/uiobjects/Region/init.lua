return (function(self)
  local ud = u(self)
  ud.visible = not ud.parent or u(ud.parent).visible
end)(...)
