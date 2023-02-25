return (function(self, level)
  self.frameLevel = assert(tonumber(level), 'invalid level')
  for _, kid in ipairs({ self:GetChildren() }) do
    if not kid:HasFixedFrameLevel() then
      kid:SetFrameLevel(self.frameLevel + 1)
    end
  end
end)(...)
