local isRealStratum = {
  BACKGROUND = true,
  BLIZZARD = true,
  DIALOG = true,
  FULLSCREEN = true,
  FULLSCREEN_DIALOG = true,
  HIGH = true,
  LOW = true,
  MEDIUM = true,
  TOOLTIP = true,
}

return function(self, strata)
  local upper = strata:upper()
  if upper == 'BLIZZARD' and not self.forbidden then
    -- issue #782: BLIZZARD is reserved for forbidden frames; it no-ops
    -- otherwise, confirmed against a real client.
    return
  end
  -- issue #782: anything that isn't a real stratum -- including the literal
  -- string "PARENT" -- resolves the same as never having been set at all:
  -- inherit the parent's current strata, confirmed against a real client.
  local resolved = isRealStratum[upper] and upper or (self.parent and self.parent:GetFrameStrata() or 'MEDIUM')
  self.frameStrata = resolved
  for kid in self.children:entries() do
    if kid:IsObjectType('frame') and not kid:HasFixedFrameStrata() then
      kid:SetFrameStrata(resolved)
    end
  end
end
