return (function(self)
  -- TODO handle relative argument to SetAllPoints
  local relative = nil
  m(self, 'SetPoint', 'TOPLEFT', relative, 'TOPLEFT', 0, 0)
  m(self, 'SetPoint', 'BOTTOMRIGHT', relative, 'BOTTOMRIGHT', 0, 0)
end)(...)
