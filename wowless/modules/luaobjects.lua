local luaobject = require('wowless.luaobject')

return function(cstubs, datalua)
  local config = datalua.config.modules and datalua.config.modules.luaobjects or {}
  local typeids = {}
  local impltypes = {}

  local function LoadTypes(modules)
    local type_stubs = cstubs.loadluaobjects(modules, luaobject, config.tostring_metamethod)
    for k, ts in pairs(type_stubs) do
      typeids[k] = ts.typeid
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

  local function CreateProxy(obj)
    assert(type(obj) == 'table', 'not a luaobject env')
    local typeid = assert(obj[1], 'not a luaobject env')
    return luaobject.new(typeid, obj)
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
