local bubblewrap = require('wowless.bubblewrap')
local mixin = require('wowless.util').mixin

return function(datalua)
  local objs = setmetatable({}, { __mode = 'k' })
  local mtps = {}

  for k, v in pairs(datalua.luaobjects) do
    local methods = {}
    for vk in pairs(v) do
      methods[vk] = bubblewrap(function() end)
    end

    local mt
    mt = {
      __eq = function(u1, u2)
        return objs[u1].table == objs[u2].table
      end,
      __index = function(u, key)
        return methods[key] or objs[u].table[key]
      end,
      __metatable = false,
      __newindex = function(u, key, value)
        if methods[key] or mt[key] ~= nil then
          error('Attempted to assign to read-only key ' .. key)
        end
        objs[u].table[key] = value
      end,
      __tostring = function(u)
        return k .. ': ' .. tostring(objs[u].table):sub(8)
      end,
    }

    local mtp = newproxy(true)
    mixin(getmetatable(mtp), mt)
    mtps[k] = mtp
  end

  local function Create(k)
    local mt = assert(mtps[k], k)
    local p = newproxy(mt)
    objs[p] = { type = k, table = {} }
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
