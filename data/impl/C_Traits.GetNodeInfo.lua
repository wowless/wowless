local datalua, talents, units, baseSql, entriesSqlCursor, edgesSqlCursor, groupsSqlCursor, conditionsSqlCursor = ...
return function(configID, nodeID)
  -- TODO mix in the state to determine the state dependent fields

  local returnPlayerData = (configID == talents.activeConfigID)
  local returnInspectData = (configID == datalua.globals.Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID)

  -- if invalid configID: empty return
  if not returnPlayerData and not returnInspectData then
    return
  end

  local player = units.player
  local specID = (returnPlayerData and player.spec) or (returnInspectData and talents.viewLoadoutSpecID)

  if returnInspectData and not talents.viewLoadoutDataImported then
    error('C_ClassTalents.ViewLoadout should be called before C_Traits.GetNodeInfo when using VIEW_TRAIT_CONFIG_ID')
  end

  -- if not visible: return zeroed out fields
  local zeroedNodeInfo = {
    meetsEdgeRequirements = false,
    entryIDs = {},
    ID = 0,
    posX = 0,
    posY = 0,
    canPurchaseRank = false,
    currentRank = 0,
    visibleEdges = {},
    isVisible = false,
    entryIDsWithCommittedRanks = {},
    maxRanks = 0,
    isCascadeRepurchasable = false,
    flags = 0,
    conditionIDs = {},
    type = 0,
    activeRank = 0,
    groupIDs = {},
    isAvailable = false,
    ranksPurchased = 0,
    canRefundRank = false,
  }

  local foundNodeID, posX, posY, nodeType, nodeFlags = baseSql(nodeID)
  if not foundNodeID then
    return zeroedNodeInfo
  end

  local isVisible = true
  local forceVisible = false
  local conditions = {}
  for conditionInfo in conditionsSqlCursor(nodeID) do
    local conditionID = conditionInfo.ID
    local conditionType = conditionInfo.CondType
    local conditionSpec = conditionInfo.specID
    if
      (conditionSpec == specID or 0 == conditionSpec)
      and (
        conditionType == datalua.globals.Enum.TraitConditionType.Visible
        or conditionType == datalua.globals.Enum.TraitConditionType.Granted
      )
    then
      forceVisible = true
    end
    if
      conditionSpec ~= specID
      and 0 ~= conditionSpec
      and conditionType == datalua.globals.Enum.TraitConditionType.Visible
    then
      isVisible = false
    end
    conditions[conditionID] = true
  end
  local conditionIDs = {}
  for conditionID, _ in pairs(conditions) do
    table.insert(conditionIDs, conditionID)
  end

  isVisible = forceVisible or isVisible
  if not isVisible then
    return zeroedNodeInfo
  end

  local entryIDs = {}
  local maxRanks = 0
  for entryInfo in entriesSqlCursor(nodeID) do
    maxRanks = entryInfo.MaxRanks
    table.insert(entryIDs, entryInfo.ID)
  end

  local visibleEdges = {}
  for edgeInfo in edgesSqlCursor(nodeID) do
    table.insert(visibleEdges, {
      targetNode = edgeInfo.TargetNodeID,
      type = edgeInfo.Type,
      visualStyle = edgeInfo.VisualStyle,
      isActive = false, -- state
    })
  end

  local groupIDs = {}
  for groupID in groupsSqlCursor(nodeID) do
    table.insert(groupIDs, groupID)
  end

  return {
    meetsEdgeRequirements = false, -- state
    entryIDs = entryIDs,
    ID = nodeID,
    posX = posX,
    posY = posY,
    canPurchaseRank = false, -- state
    currentRank = 0, -- state
    visibleEdges = visibleEdges,
    isVisible = true,
    entryIDsWithCommittedRanks = {}, -- state
    maxRanks = maxRanks,
    isCascadeRepurchasable = false, -- state
    flags = nodeFlags,
    conditionIDs = conditionIDs,
    type = nodeType,
    activeRank = 0, -- state
    groupIDs = groupIDs,
    isAvailable = false, -- state
    ranksPurchased = 0, -- state
    canRefundRank = false, -- state
  }
end
