local api = ...
return function(self, text)
  self.fontstring = self.fontstring or api.UserData(self:CreateFontString())
  self.fontstring:SetText(text)
end
