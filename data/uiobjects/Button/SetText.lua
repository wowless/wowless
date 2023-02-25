return (function(self, text)
  self.fontstring = self.fontstring or self:CreateFontString()
  u(self.fontstring):SetText(text)
end)(...)
