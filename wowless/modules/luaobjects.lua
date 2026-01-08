local mixin = require('wowless.util').mixin

local function nop() end

return function(datalua)
  local objs = {}
  local mts = {}

  for k, v in pairs(datalua.luaobjects) do
    objs[k] = setmetatable({}, { __mode = 'k' })

    local index = {}
    for vk in pairs(v) do
      index[vk] = nop
    end

    local mt = newproxy(true)
    mixin(getmetatable(mt), {
      __index = index,
      __metatable = false,
      __tostring = function(u)
        return k .. ': ' .. tostring(objs[k][u]):sub(8)
      end,
    })
    mts[k] = mt
  end

  local function Create(k)
    local mt = assert(mts[k], k)
    local p = newproxy(mt)
    objs[k][p] = {}
    return p
  end

  local function IsType(k, v)
    return assert(objs[k], k)[v] ~= nil
  end

  return {
    Create = Create,
    IsType = IsType,
  }
end
