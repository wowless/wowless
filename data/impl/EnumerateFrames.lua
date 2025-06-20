local api = ...
return function(frame)
  local nextentry, arg = api.frames:entries()
  return nextentry(arg, frame)
end
