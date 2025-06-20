local api = ...
return function(self)
  return self.texture or api.datalua.build.test and 'FileData ID 0' or nil
end
