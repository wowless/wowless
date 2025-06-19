return function(self, value)
  self.checked = not not value
  if self.checkedTexture then
    self.checkedTexture:SetShown(self.checked)
  end
end
