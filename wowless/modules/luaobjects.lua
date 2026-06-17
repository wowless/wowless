local luaobject = require('wowless.luaobject')

return function(cstubs, datalua)
  local config = datalua.config.modules and datalua.config.modules.luaobjects or {}
  local typeids = {}
  local methods_by_typeid = {}
  local typename_by_typeid = {}
  local impltypes = {}

  local shared_mt
  shared_mt = {
    __eq = function(u1, u2)
      return luaobject.getenv(u1) == luaobject.getenv(u2)
    end,
    __index = function(u, key)
      local methods = methods_by_typeid[luaobject.gettypeid(u)]
      return methods[key] or luaobject.getenv(u).table[key]
    end,
    __metatable = false,
    __newindex = function(u, key, value)
      local methods = methods_by_typeid[luaobject.gettypeid(u)]
      if methods[key] or shared_mt[key] ~= nil then
        error('Attempted to assign to read-only key ' .. key)
      end
      luaobject.getenv(u).table[key] = value
    end,
    __tostring = config.tostring_metamethod and function(u)
      local k = typename_by_typeid[luaobject.gettypeid(u)]
      return k .. ': 0x' .. tostring(luaobject.getenv(u)):gsub('^%S+ 0x?0*', ''):lower()
    end or nil,
  }

  local function LoadTypes(modules)
    local type_stubs = cstubs.loadluaobjects(modules)

    for k, ts in pairs(type_stubs) do
      typeids[k] = ts.typeid
      local v = datalua.luaobjects[k]
      if not v.virtual then
        methods_by_typeid[ts.typeid] = ts.methods
        typename_by_typeid[ts.typeid] = k
      end
    end

    for k, v in pairs(datalua.luaobjects) do
      if v.impl and not v.virtual then
        impltypes[k] = modules[v.impl]
      end
    end
  end

  local function Create(k, ...)
    local impl = impltypes[k]
    local obj = { assert(typeids[k], k), table = {} }
    if impl and impl.construct then
      impl.construct(obj, ...)
    end
    return obj
  end

  local function Coerce(k, value)
    local impl = impltypes[k]
    if impl and impl.coerce then
      local obj = { assert(typeids[k], k), table = {} }
      if impl.coerce(obj, value) then
        return obj
      end
    end
  end

  local function CreateProxy(typename, obj)
    assert(type(obj) == 'table', 'not a luaobject env')
    local typeid = assert(typeids[typename], typename)
    local np = luaobject.new(typeid, shared_mt, obj)
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
