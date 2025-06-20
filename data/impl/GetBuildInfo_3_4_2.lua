local datalua = ...
local p = datalua.build
return function()
  return p.version, p.build, p.date, p.tocversion, '', ' ', p.tocversion
end
