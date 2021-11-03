local env = ...

return {
  api = {
    GetMapInfo = function(uiMapID)
      return {
        flags = 0,
        mapID = uiMapID,
        mapType = 0,
        name = 'TheMap',
        parentMapID = 0,
      }
    end,
    GetUserWaypointPositionForMap = function()
      return env.Mixin({x=1, y=1}, env.Vector2DMixin)
    end,
  },
}
