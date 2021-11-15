return (function(self, value)
  local ud = u(self)
  ud.mouseClickEnabled = not not value
  ud.mouseMotionEnabled = not not value
end)(...)
