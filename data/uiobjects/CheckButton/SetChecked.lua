return (function(self, value)
  local ud = u(self)
  ud.checked = not not value
  if ud.checkedTexture then
    ud.checkedTexture:SetShown(ud.checked)
  end
end)(...)
