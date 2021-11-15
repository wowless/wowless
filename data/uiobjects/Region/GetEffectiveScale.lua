return (function(self)
  local ud = u(self)
  if not ud.parent or ud.isIgnoringParentScale then
    return ud.scale
  else
    return m(ud.parent, 'GetEffectiveScale') * ud.scale
  end
end)(...)
