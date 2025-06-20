local sql = ...
return function(specID, sex)
  return sql(specID, sex)
end
