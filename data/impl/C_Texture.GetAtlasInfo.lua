local atlas, sql = ...
return function(atlasName)
  return atlas.GetAtlasInfo(nil, sql(atlasName))
end
