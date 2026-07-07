_G.EluneScriptcaseFailures = {}

_G.case = function(name, func)
  local olderrorhandler = geterrorhandler()
  local errors = {}
  seterrorhandler(function(err)
    table.insert(errors, err)
  end)
  securecall(func)
  if olderrorhandler then
    seterrorhandler(olderrorhandler)
  end
  if #errors > 0 then
    _G.EluneScriptcaseFailures[name] = errors
  end
end
