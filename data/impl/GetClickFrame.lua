local env, uiobjects = ...
return function(name)
  -- TODO a real implementation of GetClickFrame
  local frame = env.genv[name]
  return frame and uiobjects.UserData(frame)
end
