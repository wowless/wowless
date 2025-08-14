local atlas, sql = ...
return function(atlasName)
  return atlas(sql(atlasName))
end
