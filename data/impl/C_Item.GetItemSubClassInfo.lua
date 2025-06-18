local sql, itemClassID, itemSubClassID = ...
local subClassName, subClassUsesInvType = sql(itemClassID, itemSubClassID)
if subClassName then
  return subClassName, subClassUsesInvType ~= 0
end
