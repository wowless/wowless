local T = ...
local name = 'WowlessGetClickFrameTestFrame'
local frame = T.env.CreateFrame('Frame', name)
return T.match(1, frame, T.env.GetClickFrame(name))
