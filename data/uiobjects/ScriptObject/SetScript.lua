local api = ...
return function(self, name, script)
  api.SetScript(self, name, 1, script)
end
