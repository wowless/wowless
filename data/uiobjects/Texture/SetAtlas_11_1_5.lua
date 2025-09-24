local atlas, sql = ...
return function(self, name)
  if name == nil then
    -- TODO error here instead of silently ignoring
    return
  end
  return atlas.SetAtlas(self, name, sql(name))
end
