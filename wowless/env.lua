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
  api.env.forceinsecure = taint and forceinsecure or function() end
  util.recursiveMixin(api.env, require('wowapi.loader').loadFunctions(api, loader))
  Mixin(api.uiobjectTypes, require('wowapi.uiobjects')(api, loader))
  local function load(f)
    return (require('wowapi.yaml').parseFile(('data/products/%s/%s.yaml'):format(loader.product, f)))
  end
  Mixin(api.env, load('globals'))
  -- TODO put this somewhere else
  local cvarDefaults = {}
  for k, v in pairs(load('cvars')) do
    cvarDefaults[k] = type(v) == 'string' and v or v[loader.product]
  end
  api.env.C_CVar.GetCVarDefault = debug.newcfunction(function(k)
    return cvarDefaults[k]
  end)
  api.env.C_Console.GetAllCommands = debug.newcfunction(function()
    local t = {}
    for k in require('pl.tablex').sort(cvarDefaults) do
      table.insert(t, { command = k })
    end
    return t
  end)
  api.env.__wowless = {
    dump = dump(api),
    product = loader.product,
  }
end

return {
  init = init,
}
