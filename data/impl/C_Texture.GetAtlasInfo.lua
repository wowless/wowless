local atlas, sql = ...
return function(atlasName)
  return atlas(nil, sql(atlasName))
end
