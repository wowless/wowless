return function(self, strata)
  -- issue #782: BLIZZARD is reserved for forbidden frames; it no-ops
  -- otherwise. PARENT resolution isn't supported here at all -- confirmed
  -- against a real client -- only the XML frameStrata attribute (see
  -- xmlattrlang.framestrata in loader.lua) resolves it.
  if strata ~= 'BLIZZARD' or self.forbidden then
    self.frameStrata = strata
  end
end
