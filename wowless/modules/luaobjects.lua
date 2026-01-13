local bubblewrap = require('wowless.bubblewrap')
local mixin = require('wowless.util').mixin

return function(datalua)
  local config = datalua.config.modules and datalua.config.modules.luaobjects or {}
  local objs = setmetatable({}, { __mode = 'k' })
  local mtps = {}
  local impltypes = {}

  local function LoadTypes(modules)
    for k, v in pairs(datalua.luaobjects) do
      local impl = v.impl and modules[v.impl]
      impltypes[k] = impl

      local methods = {}
      for mk in pairs(v.methods) do
        local mfn = impl and impl.methods and impl.methods[mk]
        if mfn then
          methods[mk] = bubblewrap(function(u, ...)
            return mfn(objs[u], ...)
          end)
        else
          methods[mk] = bubblewrap(function() end)
        end
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
        __tostring = config.tostring_metamethod and function(u)
          return k .. ': ' .. tostring(objs[u].table):sub(8)
        end or nil,
      }

      local mtp = newproxy(true)
      mixin(getmetatable(mtp), mt)
      mtps[k] = mtp
    end
  end

  local function make(k)
    local p = newproxy(assert(mtps[k], k))
    local obj = { type = k, table = {}, luarep = p }
    objs[p] = obj
    return p, obj
  end

  local function Create(k, ...)
    local impl = impltypes[k]
    local _, obj = make(k)
    if impl and impl.construct then
      impl.construct(obj, ...)
    end
    return obj
  end

  local function Coerce(k, value)
    local impl = impltypes[k]
    if impl and impl.coerce then
      local _, obj = make(k)
      if impl.coerce(obj, value) then
        return obj
      end
    end
  end

  local function CreateProxy(obj)
    assert(obj and obj.luarep, 'not a luaobject')
    local np = newproxy(mtps[obj.type])
    objs[np] = obj
    return np
  end

  local function UserData(p)
    return objs[p]
  end

  local function IsType(k, v)
    local obj = objs[v]
    return obj ~= nil and obj.type == k
  end

  return {
    Coerce = Coerce,
    Create = Create,
    CreateProxy = CreateProxy,
    IsType = IsType,
    LoadTypes = LoadTypes,
    UserData = UserData,
  }
end
