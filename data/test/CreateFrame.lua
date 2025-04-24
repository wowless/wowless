local T = ...
return {
  failures = function()
    local types = {
      -- 'ModelFFX', -- glue only TODO reenable when we can handle different warnings
      'NonsenseType',
      'PingPin',
      'PingPinFrame',
    }
    local t = {}
    for _, v in ipairs(types) do
      t[v] = function()
        assert(not pcall(T.env.CreateFrame, v))
      end
    end
    return t
  end,
  parent = function()
    return {
      frame = function()
        local parent = T.env.CreateFrame('Frame')
        local frame = T.env.CreateFrame('Frame', nil, parent)
        return T.match(1, parent, frame:GetParent())
      end,
      ['nil'] = function()
        local frame = T.env.CreateFrame('Frame', nil, nil)
        return T.match(1, nil, frame:GetParent())
      end,
      string = function()
        local pname = 'WowlessFrameParentTest'
        T.env.CreateFrame('Frame', pname)
        assert(not pcall(T.env.CreateFrame, 'Frame', nil, pname))
      end,
      unset = function()
        local frame = T.env.CreateFrame('Frame', nil)
        return T.match(1, nil, frame:GetParent())
      end,
    }
  end,
}
