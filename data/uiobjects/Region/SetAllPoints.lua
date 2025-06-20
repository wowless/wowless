return function(self)
  -- TODO handle relative argument to SetAllPoints
  local relative = nil
  self:SetPoint('TOPLEFT', relative, 'TOPLEFT', 0, 0)
  self:SetPoint('BOTTOMRIGHT', relative, 'BOTTOMRIGHT', 0, 0)
end
