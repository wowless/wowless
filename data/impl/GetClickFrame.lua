local api = ...
return function(name)
  -- TODO a real implementation of GetClickFrame
  local frame = api.env[name]
  return frame and api.UserData(frame)
end
