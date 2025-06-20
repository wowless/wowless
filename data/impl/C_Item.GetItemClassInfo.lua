local sql = ...
return function(itemClassID)
  return (sql(itemClassID))
end
