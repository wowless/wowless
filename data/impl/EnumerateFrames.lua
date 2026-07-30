local api = ...
local nextentry, arg = api.frames:entries()
return function(frame)
  return nextentry(arg, frame)
end
