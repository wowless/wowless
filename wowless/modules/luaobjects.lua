local bubblewrap = require('wowless.bubblewrap')
local mixin = require('wowless.util').mixin

return function(datalua)
  local config = datalua.config.modules and datalua.config.modules.luaobjects or {}
  local mtps = {}
  local objs = setmetatable({}, { __mode = 'k' })
  local impltypes = {}

  local function LoadTypes(modules)
    local funcheck = modules.funcheck
    local allmethods = {}

    local function createMethods(k)
      if allmethods[k] then
        return allmethods[k]
      end
      local v = datalua.luaobjects[k]
      local sandboxindex = {}
      if v.inherits then
        mixin(sandboxindex, createMethods(v.inherits))
      end
      for mk, mv in pairs(v.methods) do
        local fname = k .. ':' .. mk
        local args = {}
        for _, m in ipairs(mv.modules or {}) do
          table.insert(args, (assert(modules[m], m)))
        end
        local mfn = assert(loadstring_untainted(mv.impl))(unpack(args))
        local sandboxDispatch
        if mv.sandboximpl then
          local sbargs = {}
          for _, sm in ipairs(mv.sandboxmodules or {}) do
            table.insert(sbargs, (assert(modules[sm], sm)))
          end
          sandboxDispatch = assert(loadstring_untainted(mv.sandboximpl, fname))(unpack(sbargs))
        else
          local incheck = mv.inputs and funcheck.makeCheckInputs(fname, mv)
          local outcheck = mv.outputs and funcheck.makeCheckOutputs(fname, mv)
          local sandboxfn
          if not incheck and not outcheck then
            sandboxfn = mfn
          elseif not incheck then
            sandboxfn = function(...)
              return outcheck(mfn(...))
            end
          elseif not outcheck then
            sandboxfn = function(self, ...)
              return mfn(self, incheck(...))
            end
          else
            sandboxfn = function(self, ...)
              return outcheck(mfn(self, incheck(...)))
            end
          end
          sandboxDispatch = function(obj, ...)
            return sandboxfn(objs[obj], ...)
          end
        end
        sandboxindex[mk] = bubblewrap(sandboxDispatch)
      end
      allmethods[k] = sandboxindex
      return sandboxindex
    end

    for k in pairs(datalua.luaobjects) do
      createMethods(k)
    end

    for k, v in pairs(datalua.luaobjects) do
      if not v.virtual then
        local sandboxmethods = allmethods[k]

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
