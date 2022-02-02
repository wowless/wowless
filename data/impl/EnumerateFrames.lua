local api, frame = ...
if frame == nil then
  return api.frames[1]
else
  local idx = api.UserData(frame).frameIndex
  return idx ~= #api.frames and api.frames[idx + 1] or nil
end
