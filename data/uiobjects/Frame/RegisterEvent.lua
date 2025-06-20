local api = ...
return function(self, event)
  return api.modules.events.RegisterEvent(self, event)
end
