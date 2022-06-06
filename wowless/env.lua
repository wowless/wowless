local bitlib = require('bit')
local ext = require('wowless.ext')
local utf8 = require('lua-utf8')
local util = require('wowless.util')
local Mixin = util.mixin

local function mkBaseEnv()
  return {
    abs = math.abs,
    assert = assert,
    bit = {
      band = bitlib.band,
      bnot = bitlib.bnot,
      bor = bitlib.bor,
      bxor = bitlib.bxor,
      lshift = bitlib.lshift,
      rshift = bitlib.rshift,
    },
    ceil = math.ceil,
    collectgarbage = collectgarbage,
    coroutine = {
      create = coroutine.create,
      resume = coroutine.resume,
      running = coroutine.running,
      status = coroutine.status,
      yield = coroutine.yield,
    },
    cos = math.cos,
    date = os.date,
    debugstack = ext.traceback,
    difftime = os.difftime,
    error = error,
    floor = math.floor,
    forceinsecure = function() end, -- TODO use real forceinsecure
    format = string.format,
    getmetatable = getmetatable,
    getn = table.getn,
    gmatch = string.gmatch,
    gsub = string.gsub,
    ipairs = ipairs,
    issecure = issecure,
    issecurevariable = issecurevariable,
    math = {
      abs = math.abs,
      ceil = math.ceil,
      cos = math.cos,
      floor = math.floor,
      fmod = math.fmod,
      huge = math.huge,
      log = math.log,
      max = math.max,
      min = math.min,
      modf = math.modf,
      pi = math.pi,
      pow = math.pow,
      rad = math.rad,
      random = math.random,
      sin = math.sin,
      sqrt = math.sqrt,
    },
    max = math.max,
    min = math.min,
    mod = math.fmod,
    newproxy = newproxy,
    next = next,
    pairs = pairs,
    pcall = pcall,
    PI = math.pi,
    print = print,
    rad = math.rad,
    random = math.random,
    rawget = rawget,
    rawset = rawset,
    scrub = scrub,
    select = select,
    setfenv = setfenv,
    setmetatable = setmetatable,
    sin = math.sin,
    sort = table.sort,
    strfind = string.find,
    string = {
      byte = string.byte,
      char = string.char,
      find = string.find,
      format = string.format,
      gmatch = string.gmatch,
      gsub = string.gsub,
      join = util.strjoin,
      len = string.len,
      lower = string.lower,
      match = string.match,
      rep = string.rep,
      split = util.strsplit,
      sub = string.sub,
      trim = util.strtrim,
      upper = string.upper,
    },
    strbyte = string.byte,
    strcmputf8i = utf8.ncasecmp,
    strjoin = util.strjoin,
    strlen = string.len,
    strlenutf8 = utf8.len,
    strlower = string.lower,
    strmatch = string.match,
    strrep = string.rep,
    strsplit = util.strsplit,
    strsub = string.sub,
    strtrim = util.strtrim,
    strupper = string.upper,
    table = {
      concat = table.concat,
      foreach = function(t, fn)
        for i, v in ipairs(t) do
          fn(i, v)
        end
      end,
      getn = table.getn,
      insert = table.insert,
      remove = table.remove,
      sort = table.sort,
      wipe = util.twipe,
    },
    time = os.time,
    tinsert = table.insert,
    tonumber = tonumber,
    tostring = tostring,
    tremove = table.remove,
    type = type,
    unpack = unpack,
    wipe = util.twipe,
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

local function init(api, loader)
  api.env._G = api.env
  api.env.__dump = dump(api)
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
