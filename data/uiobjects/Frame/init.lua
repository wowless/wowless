return (function(self)
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
end)(...)
