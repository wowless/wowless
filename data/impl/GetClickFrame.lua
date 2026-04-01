local env, uiobjects = ...
return function(name)
  local frame = env.genv[name]
  if frame then
    local ud = uiobjects.UserData(frame)
    if ud and ud.name == name then
      return ud
    end
  end
  return nil
end
