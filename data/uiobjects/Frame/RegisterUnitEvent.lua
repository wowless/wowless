local api = ...
return function(self, event) -- unit1, unit2
  -- TODO actually do unit filtering
  return api.modules.events.RegisterEvent(self, event)
end
