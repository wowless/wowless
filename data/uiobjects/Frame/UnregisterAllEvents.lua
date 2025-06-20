local api = ...
return function(self)
  return api.modules.events.UnregisterAllEvents(self)
end
