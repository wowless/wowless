local util = require('wowless.util')
local Mixin = util.mixin

local function mkBaseEnv()
  return {
    abs = math.abs,
    ceil = math.ceil,
    cos = math.cos,
    floor = math.floor,
    format = string.format,
    getn = table.getn,
    gmatch = string.gmatch,
    gsub = string.gsub,
    math = {
      huge = math.huge,
      pi = math.pi,
    },
    max = math.max,
    min = math.min,
    mod = math.fmod,
    PI = math.pi,
    rad = math.rad,
    random = math.random,
    setfenv = setfenv,
    sin = math.sin,
    sort = table.sort,
    strbyte = string.byte,
    strfind = string.find,
    strlen = string.len,
    strlower = string.lower,
    strmatch = string.match,
    strrep = string.rep,
    strsub = string.sub,
    strupper = string.upper,
    tinsert = table.insert,
    tremove = table.remove,
    wipe = table.wipe,
  }
end

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
  Mixin(api.env, mkBaseEnv())
  util.recursiveMixin(api.env, require('wowapi.loader').loadFunctions(api, loader))
  Mixin(api.uiobjectTypes, require('wowapi.uiobjects')(api, loader))
  if loader.version == 'Mainline' then
    api.env.WOW_PROJECT_ID = 1
    api.env.WOW_PROJECT_MAINLINE = 1
  elseif loader.version == 'TBC' then
    api.env.WOW_PROJECT_ID = 5
    api.env.WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
  elseif loader.version == 'Vanilla' then
    api.env.WOW_PROJECT_ID = 2
    api.env.WOW_PROJECT_CLASSIC = 2
  end
end

return {
  init = init,
}
