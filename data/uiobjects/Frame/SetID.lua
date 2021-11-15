return (function(self, id)
  assert(type(id) == 'number', 'invalid ID ' .. tostring(id))
  u(self).id = id
end)(...)
