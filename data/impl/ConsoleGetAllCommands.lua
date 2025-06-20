local datalua = ...
return function()
  local t = {}
  for _, v in require('pl.tablex').sort(datalua.cvars) do
    table.insert(t, {
      category = datalua.globals.Enum.ConsoleCategory.None,
      command = v.name,
      commandType = datalua.globals.Enum.ConsoleCommandType.Cvar,
      help = '',
      scriptContents = '',
      scriptParameters = '',
    })
  end
  return t
end
