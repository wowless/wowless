return function(self, strata)
  -- issue #782: BLIZZARD is reserved for forbidden frames; it no-ops
  -- otherwise, confirmed against a real client.
  if strata ~= 'BLIZZARD' or self.forbidden then
    self.frameStrata = strata
  end
end
