local sql = ...
return function(unit)
  if unit then
    return sql(unit.class)
  end
end
