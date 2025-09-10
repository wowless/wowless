return function(self)
  local s = self:GetEffectiveScale()
  local l, b, w, h = self:GetRect()
  return l * s, b * s, w * s, h * s
end
