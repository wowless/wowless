local args = { ... }
local datalua = args[1]
local unitState, talentState = args[2], args[3]
local baseSql = args[4]
local entriesSqlCursor = args[5]
local edgesSqlCursor = args[6]
local groupsSqlCursor = args[7]
local conditionsSqlCursor = args[8]
local configID, nodeID = args[9], args[10]
-- if not visible: return zeroed out fields; if invalid configID: empty return
-- TODO mix in the state to determine the state dependent fields
if configID ~= talentState.activeConfigID then
  return
end

local player = unitState.guids[unitState.aliases.player]

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
    (conditionSpec == player.spec or 0 == conditionSpec)
    and (
      conditionType == datalua.globals.Enum.TraitConditionType.Visible
      or conditionType == datalua.globals.Enum.TraitConditionType.Granted
    )
  then
    forceVisible = true
  end
  if
    conditionSpec ~= player.spec
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
