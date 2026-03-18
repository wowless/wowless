local T, CreateFrame, GetClickFrame = ...
local name = 'WowlessGetClickFrameTestFrame'
local frame = CreateFrame('Frame', name)
return T.match(1, frame, GetClickFrame(name))
