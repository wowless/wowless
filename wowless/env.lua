local Mixin = require('wowless.util').mixin
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
  api.env._G = api.env
  Mixin(api.env, deepcopy(api.impls))
  Mixin(api.env, deepcopy(api.datalua.globals))
  api.env.__wowless = {
    dump = dump(api),
    product = api.product,
  }
end

return {
  init = init,
}
