local luaobject = require('wowless.luaobject')

return function(cstubs, datalua)
  local config = datalua.config.modules and datalua.config.modules.luaobjects or {}
  local typeids = {}
  local metatables = {}
  local impltypes = {}

  local function LoadTypes(modules)
    local type_stubs = cstubs.loadluaobjects(modules)

    -- Build methods tables with inheritance so that inherited methods share the
    -- same Lua function object across types (type_stubs has all types including virtual).
    local allmethods = {}
    local function createMethods(k)
      if allmethods[k] then
        return allmethods[k]
      end
      local v = datalua.luaobjects[k]
      local methods = {}
      if v.inherits then
        for mk, mfn in pairs(createMethods(v.inherits)) do
          methods[mk] = mfn
        end
      end
      local ts = type_stubs[k]
      if ts then
        for mk, mfn in pairs(ts.methods) do
          methods[mk] = mfn
        end
      end
      allmethods[k] = methods
      return methods
    end

    for k, ts in pairs(type_stubs) do
      typeids[k] = ts.typeid
      local v = datalua.luaobjects[k]
      if not v.virtual then
        local methods = createMethods(k)
        local mt
        mt = {
          __eq = function(u1, u2)
            return luaobject.getenv(u1) == luaobject.getenv(u2)
          end,
          __index = function(u, key)
            return methods[key] or luaobject.getenv(u)[key]
          end,
          __metatable = false,
          __newindex = function(u, key, value)
            if methods[key] or mt[key] ~= nil then
              error('Attempted to assign to read-only key ' .. key)
            end
            luaobject.getenv(u)[key] = value
          end,
          __tostring = config.tostring_metamethod and function(u)
            return k .. ': 0x' .. tostring(luaobject.getenv(u)):gsub('^%S+ 0x?0*', ''):lower()
          end or nil,
        }
        metatables[k] = mt
      end
    end

    for k, v in pairs(datalua.luaobjects) do
      if v.impl and not v.virtual then
        impltypes[k] = modules[v.impl]
      end
    end
  end

  local function make(k)
    local typeid = assert(typeids[k], k)
    local env = { typeid }
    luaobject.new(typeid, metatables[k], env)
    return env
  end

  local function Create(k, ...)
    local impl = impltypes[k]
    local obj = make(k)
    if impl and impl.construct then
      impl.construct(obj, ...)
    end
    return obj
  end

  local function Coerce(k, value)
    local impl = impltypes[k]
    if impl and impl.coerce then
      local obj = make(k)
      if impl.coerce(obj, value) then
        return obj
      end
    end
  end

  local function CreateProxy(typename, obj)
    assert(type(obj) == 'table', 'not a luaobject env')
    local typeid = assert(typeids[typename], typename)
    local np = luaobject.new(typeid, metatables[typename], obj)
    return np
  end

  local function IsType(typename, obj)
    return type(obj) == 'table' and obj[1] == typeids[typename]
  end

  local function UserData(p)
    return luaobject.getenv(p)
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
