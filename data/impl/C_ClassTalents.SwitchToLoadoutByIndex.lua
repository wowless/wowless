local events = ...
return function(loadoutIndex)
  events.SendEvent('CLASS_TALENTS_SWITCH_TO_LOADOUT_BY_INDEX', loadoutIndex)
end
