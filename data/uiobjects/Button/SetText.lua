return (function(self, text)
  self.fontstring = self.fontstring or u(self:CreateFontString())
  self.fontstring:SetText(text)
end)(...)
