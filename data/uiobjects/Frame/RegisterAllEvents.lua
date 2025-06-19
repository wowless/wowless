local api = ...
return function(self)
  return api.modules.events.RegisterAllEvents(self)
end
