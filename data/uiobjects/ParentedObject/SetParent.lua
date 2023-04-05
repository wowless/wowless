return (function(self, parent)
  if type(parent) == 'string' then
    parent = api.env[parent]
  end
  api.SetParent(self, parent and u(parent))
end)(...)
