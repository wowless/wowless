local validStrata = {
  BACKGROUND = 'BACKGROUND',
  BLIZZARD = 'BLIZZARD',
  DIALOG = 'DIALOG',
  FULLSCREEN = 'FULLSCREEN',
  FULLSCREEN_DIALOG = 'FULLSCREEN_DIALOG',
  HIGH = 'HIGH',
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  TOOLTIP = 'TOOLTIP',
}

return function(self, strata)
  local canonical = validStrata[strata:upper()]
  local resolved
  if canonical == 'BLIZZARD' and not self.forbidden then
    -- issue #782: BLIZZARD is reserved for forbidden frames; it no-ops
    -- otherwise, confirmed against a real client.
    return
  elseif canonical then
    resolved = canonical
  else
    -- issue #782: any value that isn't a real stratum -- including the
    -- literal string "PARENT" -- resolves the same as never having been
    -- set at all: inherit the parent's current strata, confirmed against
    -- a real client.
    resolved = self.parent and self.parent:GetFrameStrata() or 'MEDIUM'
  end
  self.frameStrata = resolved
  for kid in self.children:entries() do
    if kid:IsObjectType('frame') and not kid:HasFixedFrameStrata() then
      kid:SetFrameStrata(resolved)
    end
  end
end
