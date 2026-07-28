local datalua = ...
local commandType = datalua.globals.Enum.ConsoleCommandType.Cvar
local category = datalua.globals.Enum.ConsoleCategory.Default
return function()
  local t = {}
  for k in require('pl.tablex').sort(datalua.cvars) do
    table.insert(t, {
      category = category,
      command = k,
      commandType = commandType,
      scriptContents = '',
      scriptParameters = '',
    })
  end
  return t
end
