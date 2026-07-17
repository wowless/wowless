local datalua = ...
return function(self, strata)
  local upper = strata:upper()
  if upper == 'BLIZZARD' and not self.forbidden then
    -- issue #782: BLIZZARD is reserved for forbidden frames; it no-ops
    -- otherwise, confirmed against a real client.
    return
  end
  -- issue #782: WORLD is reserved for WorldFrame, which gets it directly at
  -- creation (see loader.lua) -- it isn't settable through here, same as
  -- any other invalid value (including the literal string "PARENT"),
  -- confirmed against a real client: anything not settable resolves the
  -- same as never having been set at all, inheriting the parent's current
  -- strata.
  local isValid = upper ~= 'WORLD' and datalua.stringenums.FrameStrata[upper]
  local resolved = isValid and upper or (self.parent and self.parent:GetFrameStrata() or 'MEDIUM')
  self.frameStrata = resolved
  for kid in self.children:entries() do
    if kid:IsObjectType('frame') and not kid:HasFixedFrameStrata() then
      kid:SetFrameStrata(resolved)
    end
  end
end
