local bubblewrap = require('wowless.bubblewrap')
local mixin = require('wowless.util').mixin

return function(datalua, funtainer)
  local implModules = {
    funtainer = funtainer,
  }

  local config = datalua.config.modules and datalua.config.modules.luaobjects or {}
  local objs = setmetatable({}, { __mode = 'k' })
  local mtps = {}
  local implsByType = {}

  for k, v in pairs(datalua.luaobjects) do
    local impl = v.impl and implModules[v.impl]
    if impl then
      implsByType[k] = impl
    end

    local methods = {}
    for mk in pairs(v.methods) do
      if impl and impl.methods and impl.methods[mk] then
        methods[mk] = bubblewrap(function(u, ...)
          return impl.methods[mk](objs[u].state, ...)
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

  local function make(k, state)
    local p = newproxy(assert(mtps[k], k))
    objs[p] = { type = k, table = {}, state = state }
    return p
  end

  local function Create(k, ...)
    local impl = implsByType[k]
    return make(k, impl and impl.create(...) or nil)
  end

  local function Coerce(k, value)
    local impl = implsByType[k]
    local state = impl and impl.coerce and impl.coerce(value)
    return state and make(k, state)
  end

  local function CreateProxy(p)
    local obj = assert(objs[p], 'not a luaobject')
    local np = newproxy(mtps[obj.type])
    objs[np] = obj
    return np
  end

  local function GetState(p)
    local obj = objs[p]
    return obj and obj.state
  end

  local function IsType(k, v)
    local obj = objs[v]
    return obj ~= nil and obj.type == k
  end

  return {
    Coerce = Coerce,
    Create = Create,
    CreateLuaFunctionContainer = function(callback)
      return Create('LuaFunctionContainer', callback)
    end,
    CreateProxy = CreateProxy,
    GetState = GetState,
    IsType = IsType,
  }
end
