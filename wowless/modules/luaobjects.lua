local mixin = require('wowless.util').mixin

local function nop() end

return function(datalua)
  local objs = setmetatable({}, { __mode = 'k' })
  local mts = {}

  for k, v in pairs(datalua.luaobjects) do
    local index = {}
    for vk in pairs(v) do
      index[vk] = nop
    end

    local mt = newproxy(true)
    mixin(getmetatable(mt), {
      __index = index,
      __metatable = false,
      __tostring = function(u)
        return k .. ': ' .. tostring(objs[u]):sub(8)
      end,
    })
    mts[k] = mt
  end

  local function Create(k)
    local mt = assert(mts[k], k)
    local p = newproxy(mt)
    objs[p] = { type = k }
    return p
  end

  local function IsType(k, v)
    local obj = objs[v]
    return obj ~= nil and obj.type == k
  end

  return {
    Create = Create,
    IsType = IsType,
  }
end
