local sql = ...
return function(itemInfo)
  -- TODO make this work for links and names too
  local itemID = tonumber(itemInfo)
  return itemID ~= nil and sql(itemID) ~= nil
end
