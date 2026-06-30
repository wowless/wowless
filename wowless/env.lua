local Mixin = require('wowless.util').mixin
local deepcopy = require('pl.tablex').deepcopy

local function dump(uiobjects)
  local function d(x)
    io.write(require('tools.prettywrite')(x))
    io.write('\n')
  end
  return function(...)
    for _, x in ipairs({ ... }) do
      d(x)
      if type(x) == 'table' and uiobjects.UserData(x) then
        print('===[begin userdata]===')
        d(uiobjects.UserData(x))
        print('===[ end userdata ]===')
      end
    end
  end
end

local function init(modules, lite)
  modules.log(1, 'loading functions')
  local impls, secureimpls = modules.cstubs.load(modules)
  modules.log(1, 'functions loaded')
  local genv = modules.env.genv
  local secureenv = modules.env.secureenv
  Mixin(genv, deepcopy(impls))
  Mixin(genv, deepcopy(modules.datalua.globals))
  Mixin(secureenv, deepcopy(secureimpls))
  Mixin(secureenv, deepcopy(modules.datalua.globals))

  for tag, text in modules.sqlitedb:urows('SELECT BaseTag, TagText_lang FROM GlobalStrings') do
    genv[tag] = text
    secureenv[tag] = text
  end

  genv._G = modules.env.genv
  genv.math.huge = math.huge
  genv.math.pi = math.pi
  secureenv.math.huge = math.huge
  secureenv.math.pi = math.pi

  local wowlessDebug = Mixin({}, debug)
  wowlessDebug.debug = function()
    -- luacheck: ignore 211
    local _G = modules.env.genv
    local function _getLocals(stackLevel)
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

  local function dumpregion(r)
    r = assert(modules.uiobjects.UserData(r))
    local p = {}
    for k, v in pairs(r.points) do
      local rt, rp, x, y = unpack(v)
      p[k] = {
        relativeTo = rt and rt:GetDebugName(),
        relativePoint = rp,
        x = x,
        y = y,
      }
    end
    io.write(require('tools.prettywrite')({
      bottom = r.bottom,
      debugname = r:GetDebugName(),
      height = r.height,
      left = r.left,
      points = p,
      right = r.right,
      top = r.top,
      width = r.width,
    }))
    io.write('\n')
  end

  local __wowless = {
    debug = wowlessDebug,
    dump = dump(modules.uiobjects),
    dumpregion = dumpregion,
    lite = lite,
    platform = modules.platform.platform,
    printf = function(fmt, ...)
      io.stdout:write(string.format(fmt, ...))
    end,
    product = modules.datalua.product,
    quit = function(exitCode)
      modules.log(1, 'Bye!')
      os.exit(exitCode or 1)
    end,
    debugstack = require('wowless.debug').debugstack,
  }
  genv.__wowless = __wowless
  secureenv.__wowless = __wowless
end

return {
  init = init,
}
