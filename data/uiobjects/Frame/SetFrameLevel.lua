return (function(self, level)
  u(self).frameLevel = assert(tonumber(level), 'invalid level')
  for _, kid in ipairs({ self:GetChildren() }) do
    if not kid:HasFixedFrameLevel() then
      kid:SetFrameLevel(u(self).frameLevel + 1)
    end
  end
end)(...)
