return function(self, level)
  self.frameLevel = assert(tonumber(level), 'invalid level')
  for kid in self.children:entries() do
    if kid:IsObjectType('frame') and not kid:HasFixedFrameLevel() then
      kid:SetFrameLevel(self.frameLevel + 1)
    end
  end
end
