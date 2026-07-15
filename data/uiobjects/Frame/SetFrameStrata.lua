return function(self, strata)
  if strata == 'PARENT' then
    self.frameStrata = self.parent and self.parent:GetFrameStrata() or 'MEDIUM'
  elseif strata ~= 'BLIZZARD' or self.forbidden then
    -- issue #782: BLIZZARD is reserved for forbidden frames; it no-ops
    -- otherwise
    self.frameStrata = strata
  end
end
