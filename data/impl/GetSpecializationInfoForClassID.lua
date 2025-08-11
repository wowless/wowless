local units, sql = ...
return function(classID, specIndex, sex)
  local player = units.player
  local id, name, desc, icon, role, mastery = sql(classID, specIndex, sex)
  if id == nil then
    return
  end
  local recommended = true -- TODO implement
  return id, name, desc, icon, role, recommended, classID == player.class, mastery, nil
end
