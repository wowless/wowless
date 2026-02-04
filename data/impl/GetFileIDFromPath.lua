local sql = ...
return function(path)
  path = string.gsub(path, '/', '\\')
  local p = string.find(path, '\\[^\\]*$')
  if not p then
    return nil
  end
  local a = string.sub(path, 1, p)
  local b = string.sub(path, p + 1)
  return (sql(a, b))
end
