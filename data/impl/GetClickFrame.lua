local api, name = ...
-- TODO a real implementation of GetClickFrame
local frame = api.env[name]
return frame and api.UserData(frame)
