local util = require('wowless.util')
local bubblewrap = require('wowless.bubblewrap')
local Mixin = util.mixin
local hlist = require('wowless.hlist')

return function(datalua, funcheck, uiobjectsmodule, uiobjecttypes)
  local InheritsFrom = uiobjecttypes.InheritsFrom
  local UserData = uiobjectsmodule.UserData

  local function flatten(types)
    local result = {}
    local function flattenOne(k)
      local lk = string.lower(k)
      if not result[lk] then
        local ty = types[k]
        local isa = { [lk] = true }
        local metaindex = {}
        for inh in pairs(ty.inherits) do
          flattenOne(inh)
          Mixin(isa, result[string.lower(inh)].isa)
          for mk, mv in pairs(result[string.lower(inh)].metaindex) do
            metaindex[mk] = mv
          end
        end
        Mixin(metaindex, ty.mixin) -- do this last in case of overrides
        result[lk] = {
          constructor = ty.constructor,
          isa = isa,
          metaindex = metaindex,
          name = ty.cfg.objectType or k,
        }
      end
    end
    for k in pairs(types) do
      flattenOne(k)
    end
    local t = {}
    for k, v in pairs(result) do
      local sandboxIndex = {}
      for n, f in pairs(v.metaindex) do
        sandboxIndex[n] = bubblewrap(function(obj, ...)
          return f(UserData(obj), ...)
        end)
      end
      t[k] = {
        constructor = v.constructor,
        hostMT = { __index = v.metaindex },
        isa = v.isa,
        name = v.name,
        sandboxMT = { __index = sandboxIndex },
      }
    end
    return t
  end
  return function(modules)
    local uiobjects = {}
    for name, cfg in pairs(datalua.uiobjects) do
      local lname = name:lower()
      local function wrap(fname, fn)
        return function(self, ...)
          if not InheritsFrom(self.type, lname) then
            error(('invalid self to %s.%s, got %s'):format(name, fname, tostring(self.type)))
          end
          return fn(self, ...)
        end
      end
      local constructor = assert(loadstring_untainted(cfg.constructor, name))(hlist)
      if cfg.singleton then
        local orig = constructor
        local called = false
        constructor = function()
          assert(not called, name .. ' can only be created once')
          called = true
          return orig()
        end
      end
      local mixin = {}
      for mname, method in pairs(cfg.methods) do
        local fname = name .. ':' .. mname
        local incheck = method.inputs and funcheck.makeCheckInputs(fname, method)
        local outcheck = method.outputs and funcheck.makeCheckOutputs(fname, method)
        local src = method.src or fname
        local mkfn = setfenv(assert(loadstring_untainted(method.impl, src), fname), _G)
        local args = {}
        for _, m in ipairs(method.modules or {}) do
          table.insert(args, (assert(modules[m], m)))
        end
        local basefn = wrap(fname, mkfn(unpack(args)))
        local outfn
        if not incheck and not outcheck then
          outfn = basefn
        elseif not incheck then
          outfn = function(...)
            return outcheck(basefn(...))
          end
        else
          outfn = function(self, ...)
            return outcheck(basefn(self, incheck(...)))
          end
        end
        mixin[mname] = outfn
      end
      uiobjects[name] = {
        cfg = cfg,
        constructor = constructor,
        inherits = cfg.inherits,
        mixin = mixin,
      }
    end
    return flatten(uiobjects)
  end
end
