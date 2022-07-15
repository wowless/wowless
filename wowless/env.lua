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
  local p = loader.product
  if p == 'wow_classic_era' or p == 'wow_classic_era_ptr' then
    api.env.WOW_PROJECT_ID = 2
    api.env.WOW_PROJECT_CLASSIC = 2
  elseif p == 'wow_classic' or p == 'wow_classic_beta' or p == 'wow_classic_ptr' then
    api.env.WOW_PROJECT_ID = 5
    api.env.WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
  elseif p == 'wow' or p == 'wowt' then
    api.env.WOW_PROJECT_ID = 1
    api.env.WOW_PROJECT_MAINLINE = 1
  elseif p ~= nil then
    error('invalid product')
  end
end

return {
  init = init,
}
