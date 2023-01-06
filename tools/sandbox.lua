local sandbox = require('wowless.sandbox').create()
sandbox:eval(([[
  local data = (function() %s end)()
  for k, v in pairs(data.globals) do
    _G[k] = v
  end
  for k, v in pairs(_G) do
    print(k, v)
  end
]]):format(require('pl.file').read('build/products/wow_classic_era/data.lua')))
