local xmleval = ...
local nextentry, arg = xmleval.frames:entries()
return function(frame)
  return nextentry(arg, frame)
end
