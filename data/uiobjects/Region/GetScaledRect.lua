return function(self)
  local s = self:GetEffectiveScale()
  local b, l, w, h = self:GetRect()
  return b * s, l * s, w * s, h * s
end
