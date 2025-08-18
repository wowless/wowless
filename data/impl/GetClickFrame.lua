local api, env = ...
return function(name)
  -- TODO a real implementation of GetClickFrame
  local frame = env.genv[name]
  return frame and api.UserData(frame)
end
