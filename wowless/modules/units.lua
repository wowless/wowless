return function()
  local player = {
    class = 1, -- Warrior
    faction = 'Horde',
    guid = 'Player-1096-06DF65C1',
    isplayer = true,
    level = 30,
    name = 'Unitname',
    race = 2, -- Orc
    sex = 2, -- Male
    spec = 71, -- Arms
  }
  return {
    GetUnit = function(unit)
      return unit:lower() == 'player' and player or nil
    end,
    player = player,
  }
end
