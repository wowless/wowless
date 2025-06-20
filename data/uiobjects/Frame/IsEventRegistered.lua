local api = ...
return function(self, event)
  return api.modules.events.IsEventRegistered(self, event)
end
