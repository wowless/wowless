local units, sql = ...
return function(specID, sex)
  local player = units.player
  local id, name, desc, icon, role, class, mastery = sql(specID, sex)
  local recommended = true -- TODO implement
  return id, name, desc, icon, role, recommended, class == player.class, mastery
end
