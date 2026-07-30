local templates = ...
local nextentry, arg = templates.frames:entries()
return function(frame)
  return nextentry(arg, frame)
end
