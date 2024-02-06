local t = ...
local name = 'WowlessGetClickFrameTestFrame'
local frame = t.env.CreateFrame('Frame', name)
t.assertEquals(frame, t.env.GetClickFrame(name))
