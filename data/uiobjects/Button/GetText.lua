return (function(self)
  local fs = u(self).fontstring
  return fs and u(fs).parent == self and m(fs, 'GetText') or nil
end)(...)
