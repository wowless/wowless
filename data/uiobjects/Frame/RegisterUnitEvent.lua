return (function(self, event) -- unit1, unit2
  -- TODO actually do unit filtering
  u(self).registeredEvents[string.lower(event)] = true
end)(...)
