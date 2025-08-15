local atlas, sql = ...
return function(atlasName)
  return atlas.GetAtlasInfo(sql(atlasName))
end
