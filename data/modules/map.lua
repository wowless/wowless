return {
  api = function()
    return {
      GetMapInfo = function(uiMapID)
        return {
          flags = 0,
          mapID = uiMapID,
          mapType = 0,
          name = 'TheMap',
          parentMapID = 0,
        }
      end,
    }
  end,
}
