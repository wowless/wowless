local loader = ...
local p = loader.product
if p == 'wow' or p == 'wowt' or p == 'wow_beta' then
  -- TODO implement for mainline
  assert(true)
else
  local tabIndex, talentIndex = select(2, ...)
  assert(tonumber(tabIndex), 'invalid tabIndex')
  assert(tonumber(talentIndex), 'invalid talentIndex')
  -- TODO implement vanilla/tbc/wrath
  return '', 0, 1, 1, 0, 1
end
