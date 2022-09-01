local sandbox = require('wowless.sandbox').create()
for k, v in pairs(require('build.products.wow_classic_era.data').globals) do
  if type(v) ~= 'table' then
    local vv = type(v) == 'string' and ('%q'):format(v) or v
    sandbox:eval(('_G[%q] = %s'):format(k, vv))
  end
end
sandbox:eval('for k, v in pairs(_G) do print(k, v) end')
