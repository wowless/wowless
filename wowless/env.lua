local bitlib = require('bit')
local extformat = require('wowless.ext').format
local util = require('wowless.util')
local Mixin = util.mixin

local function stringFormat(fmt, ...)
  local args = {...}
  for i, arg in ipairs(args) do
    fmt = fmt:gsub('%%' .. i .. '%$', arg)
  end
  return extformat(fmt, ...)
end

local function mkBaseEnv()
  return {
    abs = math.abs,
    assert = assert,
    bit = {
      band = bitlib.band,
      bnot = bitlib.bnot,
      bor = bitlib.bor,
    },
    ceil = math.ceil,
    collectgarbage = collectgarbage,
    coroutine = {
      create = coroutine.create,
      resume = coroutine.resume,
      status = coroutine.status,
      yield = coroutine.yield,
    },
    cos = math.cos,
    date = os.date,
    debugstack = debug.traceback,
    error = error,
    floor = math.floor,
    format = stringFormat,
    getmetatable = getmetatable,
    getn = table.getn,
    gmatch = string.gmatch,
    gsub = string.gsub,
    ipairs = ipairs,
    math = {
      abs = math.abs,
      ceil = math.ceil,
      cos = math.cos,
      floor = math.floor,
      huge = math.huge,
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
      format = stringFormat,
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
    strjoin = util.strjoin,
    strlen = string.len,
    strlenutf8 = string.len, -- NEEDS ACTUAL FUNCTION
    strlower = string.lower,
    strmatch = string.match,
    strrep = string.rep,
    strsplit = util.strsplit,
    strsub = string.sub,
    strtrim = util.strtrim,
    strupper = string.upper,
    table = {
      concat = table.concat,
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
  local block = require('serpent').block
  local config = { nocode = true }
  local function d(x)
    print(block(x, config))
  end
  return function(...)
    for _, x in ipairs({...}) do
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
  Mixin(api.uiobjectTypes, require('wowapi.uiobjects')(api))
end

return {
  init = init,
}
