local api = ...
return function(name)
  local t = api.templates[name:lower()]
  if t then
    return {
      height = 1,
      inherits = t.inherits and table.concat(t.inherits, ','),
      keyValues = {},
      sourceLocation = 'source',
      type = t.type,
      width = 1,
    }
  end
end
