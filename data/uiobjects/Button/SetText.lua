local uiobjects = ...
return function(self, text)
  self.fontstring = self.fontstring or uiobjects.UserData(self:CreateFontString())
  self.fontstring:SetText(text)
end
