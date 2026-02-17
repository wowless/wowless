local bubblewrap = require('wowless.bubblewrap')
local mixin = require('wowless.util').mixin

return function(datalua)
  local cstubs = require('build.products.' .. datalua.product .. '.stubs')
  local config = datalua.config.modules and datalua.config.modules.luaobjects or {}
  local objs = setmetatable({}, { __mode = 'k' })
  local mtps = {}
  local impltypes = {}

  local function LoadTypes(modules)
    local allmethods = {}

    local function createMethods(k)
      if allmethods[k] then
        return allmethods[k]
      end
      local v = datalua.luaobjects[k]
      local methods = {}
      if v.inherits then
        local parentmethods = createMethods(v.inherits)
        for mk, mfn in pairs(parentmethods) do
          methods[mk] = mfn
        end
      end
      for mk, mv in pairs(v.methods) do
        if mv.cstub then
          local cfn = assert(cstubs[k .. ':' .. mk], 'missing C stub for ' .. k .. ':' .. mk)
          methods[mk] = bubblewrap(function(u, ...)
            return cfn(objs[u], ...)
          end)
        else
          local args = {}
          for _, m in ipairs(mv.modules or {}) do
            table.insert(args, (assert(modules[m], m)))
          end
          local mfn = assert(loadstring_untainted(mv.impl))(unpack(args))
          methods[mk] = bubblewrap(function(u, ...)
            return mfn(objs[u], ...)
          end)
        end
      end
      allmethods[k] = methods
      return methods
    end

    for k in pairs(datalua.luaobjects) do
      createMethods(k)
    end

    for k, v in pairs(datalua.luaobjects) do
      if not v.virtual then
        local methods = allmethods[k]

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
        impltypes[k] = v.impl and modules[v.impl]
      end
    end
  end

  local function make(k)
    local p = newproxy(assert(mtps[k], k))
    local obj = { type = k, table = {}, luarep = p }
    objs[p] = obj
    return obj
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

  local function CreateProxy(obj)
    assert(obj and obj.luarep, 'not a luaobject')
    local np = newproxy(mtps[obj.type])
    objs[np] = obj
    return np
  end

  local function UserData(p)
    return objs[p]
  end

  return {
    Coerce = Coerce,
    Create = Create,
    CreateProxy = CreateProxy,
    LoadTypes = LoadTypes,
    UserData = UserData,
  }
end
