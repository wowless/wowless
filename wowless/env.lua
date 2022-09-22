local deepcopy = require('pl.tablex').deepcopy

local function dump(api)
  local d = require('pl.pretty').dump
  return function(...)
    for _, x in ipairs({ ... }) do
      d(x)
      if api.UserData(x) then
        print('===[begin userdata]===')
        d(api.UserData(x))
        print('===[ end userdata ]===')
      end
    end
  end
end

local function init(api, loader)
  api.impls = require('wowapi.loader').loadFunctions(api, loader)
  api.env.set('_G', api.env.getenv())
  for k, v in pairs(deepcopy(api.impls)) do
    api.env.set(k, v)
  end
  for k, v in pairs(deepcopy(api.datalua.globals)) do
    api.env.set(k, v)
  end
  api.env.set('__wowless', {
    dump = dump(api),
    product = api.product,
  })
end

return {
  init = init,
}
