-- TODO support remaining arguments
local units, chrspecialization, specIndex = ...
local player = units.guids[units.aliases.player]
local roles = {
  [0] = 'TANK',
  [1] = 'HEALER',
  [2] = 'DAMAGER',
}
for row in chrspecialization() do
  if row.ClassID == player.class and row.OrderIndex == specIndex - 1 then
    return row.ID,
      player.sex == 2 and row.FemaleName_lang or row.Name_lang,
      row.Description_lang,
      row.SpellIconFileID,
      roles[row.Role],
      0 -- TODO implement primary stat
  end
end
