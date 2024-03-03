local T = ...
local name = 'WowlessGetClickFrameTestFrame'
local frame = T.env.CreateFrame('Frame', name)
T.assertEquals(frame, T.env.GetClickFrame(name))
