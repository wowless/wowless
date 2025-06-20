return function(self, value)
  value = not not value
  if value ~= self:IsEnabled() then
    self:SetButtonState(value and 'NORMAL' or 'DISABLED')
  end
end
