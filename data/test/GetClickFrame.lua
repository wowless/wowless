local T, GetClickFrame = ...
local name = 'WowlessGetClickFrameTestFrame'
local frame = T.env.CreateFrame('Frame', name)
return T.match(1, frame, GetClickFrame(name))
