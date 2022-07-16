local util = require('wowless.util')
local Mixin = util.mixin

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

local function init(api, loader, taint)
  api.env._G = api.env
  api.env.__dump = dump(api)
  api.env.forceinsecure = taint and forceinsecure or function() end
  util.recursiveMixin(api.env, require('wowapi.loader').loadFunctions(api, loader))
  Mixin(api.uiobjectTypes, require('wowapi.uiobjects')(api, loader))
  if loader.product then
    Mixin(api.env, (require('wowapi.yaml').parseFile(('data/globals/%s.yaml'):format(loader.product))))
  end
end

return {
  init = init,
}
