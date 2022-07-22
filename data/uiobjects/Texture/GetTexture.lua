return (function(self)
  local t = u(self).texture
  return t or build.test and 'FileData ID 0' or nil
end)(...)
