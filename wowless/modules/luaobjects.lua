local bubblewrap = require('wowless.bubblewrap')
local mixin = require('wowless.util').mixin

return function(datalua)
  local config = datalua.config.modules and datalua.config.modules.luaobjects or {}
  local mtps = {}
  local hostmts = {}
  local objs = setmetatable({}, { __mode = 'k' })
  local impltypes = {}

  local function LoadTypes(modules)
    local allmethods = {}

    local function createMethods(k)
      if allmethods[k] then
        return allmethods[k]
      end
      local v = datalua.luaobjects[k]
      local hostindex = {}
      local sandboxindex = {}
      if v.inherits then
        local parent = createMethods(v.inherits)
        mixin(hostindex, parent.hostindex)
        mixin(sandboxindex, parent.sandboxindex)
      end
      for mk, mv in pairs(v.methods) do
        local args = {}
        for _, m in ipairs(mv.modules or {}) do
          table.insert(args, (assert(modules[m], m)))
        end
        local mfn = assert(loadstring_untainted(mv.impl))(unpack(args))
        hostindex[mk] = mfn
        sandboxindex[mk] = bubblewrap(function(u, ...)
          return mfn(objs[u], ...)
        end)
      end
      allmethods[k] = { hostindex = hostindex, sandboxindex = sandboxindex }
      return allmethods[k]
    end

    for k in pairs(datalua.luaobjects) do
      createMethods(k)
    end

    for k, v in pairs(datalua.luaobjects) do
      if not v.virtual then
        local m = allmethods[k]
        local sandboxmethods = m.sandboxindex

        local sandboxmt
        sandboxmt = {
          __eq = function(u1, u2)
            return objs[u1].table == objs[u2].table
          end,
          __index = function(u, key)
            return sandboxmethods[key] or objs[u].table[key]
          end,
          __metatable = false,
          __newindex = function(u, key, value)
            if sandboxmethods[key] or sandboxmt[key] ~= nil then
              error('Attempted to assign to read-only key ' .. key)
            end
            objs[u].table[key] = value
          end,
          __tostring = config.tostring_metamethod and function(u)
            return k .. ': 0x' .. tostring(objs[u].table):gsub('^%S+ 0x?0*', ''):lower()
          end or nil,
        }

        local mtp = newproxy(true)
        mixin(getmetatable(mtp), sandboxmt)
        mtps[k] = mtp
        hostmts[k] = {
          __index = function(t, key)
            return m.hostindex[key] or t.table[key]
          end,
        }
        impltypes[k] = v.impl and modules[v.impl]
      end
    end
  end

  local function make(k)
    local p = newproxy(assert(mtps[k], k))
    local obj = setmetatable({ type = k, table = {}, luarep = p }, assert(hostmts[k], k))
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
