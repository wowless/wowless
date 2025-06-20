local sql = ...
return function(slotName)
  return sql(slotName)
end
