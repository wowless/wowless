local api = ...
return function(self, event)
  return api.modules.events.UnregisterEvent(self, event)
end
