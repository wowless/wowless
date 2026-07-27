local datalua = ...
local commandType = datalua.globals.Enum.ConsoleCommandType.Cvar
return function()
  local t = {}
  for _, v in require('pl.tablex').sort(datalua.cvars) do
    table.insert(t, {
      category = v.category,
      command = v.name,
      commandType = commandType,
      help = v.help,
      scriptContents = '',
      scriptParameters = '',
    })
  end
  return t
end
