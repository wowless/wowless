return (function(self)
  local s = m(self, 'GetEffectiveScale')
  local b, l, w, h = m(self, 'GetRect')
  return b * s, l * s, w * s, h * s
end)(...)
