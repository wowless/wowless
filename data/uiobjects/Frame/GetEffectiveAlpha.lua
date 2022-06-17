return (function(self)
  local ud = u(self)
  if not ud.parent or ud.isIgnoringParentAlpha then
    return ud.alpha
  else
    return m(ud.parent, 'GetEffectiveAlpha') * ud.alpha
  end
end)(...)
