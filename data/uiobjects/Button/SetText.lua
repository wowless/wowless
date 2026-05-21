return function(self, text)
  self.fontstring = self.fontstring or self:CreateFontString()
  self.fontstring:SetText(text)
end
