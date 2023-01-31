local api, frame = ...
local nextentry = api.frames:entries()
local nextframe = nextentry(api.frames, frame and api.UserData(frame))
return nextframe and nextframe.luarep
