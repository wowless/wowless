local T, CreateFrame, GetClickFrame = ...
return {
  anonymous = function()
    local name = 'WowlessGetClickFrameTestAnonymous'
    T.check1(nil, GetClickFrame(name))
    _G[name] = CreateFrame('Frame')
    T.check1(nil, GetClickFrame(name))
  end,
  state = function()
    local name = 'WowlessGetClickFrameTestSimple'
    T.check1(nil, GetClickFrame(name))
    local frame = CreateFrame('Frame', name)
    T.check1(frame, _G[name])
    _G[name] = nil
    T.check1(nil, GetClickFrame(name))
    local frame2 = CreateFrame('Frame', name)
    T.check1(frame2, GetClickFrame(name))
  end,
  wrongname = function()
    local name1 = 'WowlessGetClickFrameTestWrongName1'
    local name2 = 'WowlessGetClickFrameTestWrongName2'
    local frame1 = CreateFrame('Frame', name1)
    local frame2 = CreateFrame('Frame', name2)
    _G[name1] = frame2
    T.check1(nil, GetClickFrame(name1))
    T.check1(frame2, GetClickFrame(name2))
    _G[name1] = frame1
    T.check1(frame1, GetClickFrame(name1))
    T.check1(frame2, GetClickFrame(name2))
  end,
}
