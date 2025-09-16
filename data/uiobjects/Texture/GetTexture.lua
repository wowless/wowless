local datalua = ...
return function(self)
  return self.texture or datalua.build.test and 'FileData ID 0' or nil
end
