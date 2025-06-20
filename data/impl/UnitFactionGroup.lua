local sql = ...
return function(unit)
  if unit then
    return sql(unit.faction)
  end
end
