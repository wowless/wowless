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
      local function Vector2D_Dot(leftX, leftY, rightX, rightY)
        return leftX * rightX + leftY * rightY;
      end
      local function Vector2D_GetLengthSquared(x, y)
        return Vector2D_Dot(x, y, x, y);
      end
      local function Vector2D_GetLength(x, y)
        return math.sqrt(Vector2D_GetLengthSquared(x, y));
      end
      return {
        Add = function() end,
        Clone = function(self) return self; end,
        Cross = function() end,
        DivideBy = function() end,
        Dot = function(self,other) return Vector2D_Dot(self.x, self.y, other:GetXY()); end,
        GetLength = function(self) return Vector2D_GetLength(self:GetXY()); end,
        GetLengthSquared = function(self) return Vector2D_GetLengthSquared(self:GetXY()); end,
        GetXY = function() return 1,1 end,
        IsEqualTo = function()return true end,
        IsZero = function() return false end,
        Normalize = function()  end,
        RotateDirection = function() end,
        ScaleBy = function() end,
        SetXY = function() return true end,
        Subtract = function() end,
      }
    end,
  },
}
