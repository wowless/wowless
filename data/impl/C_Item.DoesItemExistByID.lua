local itemByID, itemInfo = ...
-- TODO make this work for links and names too
local itemID = tonumber(itemInfo)
return itemID ~= nil and itemByID(itemID) ~= nil
