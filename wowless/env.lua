local Mixin = require('wowless.util').mixin
local deepcopy = require('pl.tablex').deepcopy

local function dump(api)
  local d = require('pl.pretty').dump
  return function(...)
    for _, x in ipairs({ ... }) do
      d(x)
      if type(x) == 'table' and api.UserData(x) then
        print('===[begin userdata]===')
        d(api.UserData(x))
        print('===[ end userdata ]===')
      end
    end
  end
end

local function init(modules, lite)
  local impls, rawimpls = modules.apiloader(modules)
  modules.api.impls = rawimpls
  modules.api.env._G = modules.api.env
  Mixin(modules.api.env, deepcopy(impls))
  Mixin(modules.api.env, deepcopy(modules.datalua.globals))
  Mixin(modules.api.secureenv, deepcopy(impls))
  Mixin(modules.api.secureenv, deepcopy(modules.datalua.globals))

  local wowlessDebug = Mixin({}, debug)
  wowlessDebug.debug = function()
    -- luacheck: ignore 211
    local _G = modules.api.env
    local function getLocals(stackLevel)
      stackLevel = (stackLevel or 0) + 5 -- 5 = 3 (this function) + 2 (caller)
      local locals = {}
      local i = 1
      while true do
        local name, value = debug.getlocal(stackLevel, i)
        if not name then
          break
        end
        locals[name] = value
        i = i + 1
      end
      return locals
    end

    print('entering debugger at ' .. debug.getinfo(2).source .. ':' .. debug.getinfo(2).currentline)
    print('get _G with: _, _G = debug.getlocal(3,1)')
    print('get locals with: locals = select(2, debug.getlocal(3,2))()')
    debug.debug()
  end

  modules.api.env.__wowless = {
    debug = wowlessDebug,
    dump = dump(modules.api),
    lite = lite,
    platform = modules.platform.platform,
    product = modules.datalua.product,
    quit = function(exitCode)
      modules.log(1, 'Bye!')
      os.exit(exitCode or 1)
    end,
  }
end

return {
  init = init,
}
