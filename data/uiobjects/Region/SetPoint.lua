return (function(self, arg1, arg2, arg3, arg4, arg5)
  -- TODO handle resetting points
  local point = arg1 or 'CENTER'
  local relativeTo = u(self).parent
  local relativePoint = 'CENTER'
  local x = 0
  local y = 0
  if type(arg2) == 'number' and type(arg3) == 'number' then
    x = arg2
    y = arg3
  else
    if type(arg2) == 'string' then
      local name = api.ParentSub(arg2, relativeTo)
      local frame = api.env[name]
      if not frame then
        api.log(1, 'SetPoint to unknown frame %q', name)
      end
      relativeTo = frame
    elseif type(arg2) == 'table' then
      relativeTo = arg2
    else
      assert(arg2 == nil)
    end
    if type(arg3) == 'number' and type(arg4) == 'number' then
      -- This is speculative based on usage in FrameXML.
      x = arg3
      y = arg4
    elseif type(arg3) == 'string' then
      relativePoint = arg3
      if type(arg4) == 'number' and type(arg5) == 'number' then
        x = arg4
        y = arg5
      end
    end
  end
  table.insert(u(self).points, { point, relativeTo, relativePoint, x, y })
end)(...)
