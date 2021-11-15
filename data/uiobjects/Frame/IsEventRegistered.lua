return (function(self, event)
  local ud = u(self)
  return ud.registeredAllEvents or not not ud.registeredEvents[string.lower(event)]
end)(...)
