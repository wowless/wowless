local util = require('wowless.util')
local bubblewrap = require('wowless.bubblewrap')
local Mixin = util.mixin

return function(datalua, funcheck, gencode, sqls, uiobjectsmodule, uiobjecttypes)
  local InheritsFrom = uiobjecttypes.InheritsFrom
  local UserData = uiobjectsmodule.UserData

  local function flatten(types)
    local result = {}
    local function flattenOne(k)
      local lk = string.lower(k)
      if not result[lk] then
        local ty = types[k]
        local isa = { [lk] = true }
        local scripts = Mixin({}, ty.scripts or {})
        local metaindex = {}
        for inh in pairs(ty.inherits) do
          flattenOne(inh)
          Mixin(isa, result[string.lower(inh)].isa)
          Mixin(scripts, result[string.lower(inh)].scripts)
          for mk, mv in pairs(result[string.lower(inh)].metaindex) do
            metaindex[mk] = mv
          end
        end
        Mixin(metaindex, ty.mixin) -- do this last in case of overrides
        result[lk] = {
          constructor = ty.constructor,
          ctype = ty.cfg.uitype_bit,
          isa = isa,
          metaindex = metaindex,
          name = ty.cfg.objectType or k,
          scripts = scripts,
        }
      end
    end
    for k in pairs(types) do
      flattenOne(k)
    end
    local t = {}
    for k, v in pairs(result) do
      local hostIndex = {}
      local sandboxIndex = {}
      for n, m in pairs(v.metaindex) do
        hostIndex[n] = m.fn
        local sandboxDispatchFn
        if m.fn ~= m.sandboxfn then
          local sf = m.sandboxfn
          sandboxDispatchFn = function(obj, ...)
            return sf(UserData(obj), ...)
          end
        else
          local fn, incheck, outcheck = m.fn, m.incheck, m.outcheck
          local sandboxfn
          if not incheck and not outcheck then
            sandboxfn = fn
          elseif not incheck then
            sandboxfn = function(...)
              return outcheck(fn(...))
            end
          elseif not outcheck then
            sandboxfn = function(self, ...)
              return fn(self, incheck(...))
            end
          else
            sandboxfn = function(self, ...)
              return outcheck(fn(self, incheck(...)))
            end
          end
          sandboxDispatchFn = function(obj, ...)
            return sandboxfn(UserData(obj), ...)
          end
        end
        sandboxIndex[n] = bubblewrap(sandboxDispatchFn)
      end
      t[k] = {
        constructor = v.constructor,
        ctype = v.ctype,
        hostMT = { __index = hostIndex }, -- issue #657
        isa = v.isa,
        name = v.name,
        sandboxMT = { __index = sandboxIndex },
        scripts = v.scripts,
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
      local constructor = assert(loadstring_untainted(cfg.constructor, name))(gencode)
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
        local mkfn = assert(loadstring_untainted(method.impl, src), fname)
        local args = {}
        for _, m in ipairs(method.modules or {}) do
          table.insert(args, (assert(modules[m], m)))
        end
        for _, sql in ipairs(method.sqls or {}) do
          table.insert(args, (assert(sqls[sql], sql)))
        end
        local sandboxbasefn = wrap(fname, mkfn(unpack(args)))
        local basefn = sandboxbasefn
        if method.hostimpl then
          local hmkfn = assert(loadstring_untainted(method.hostimpl, src), fname)
          local hargs = {}
          for _, hm in ipairs(method.hostmodules or {}) do
            table.insert(hargs, (assert(modules[hm], hm)))
          end
          basefn = wrap(fname, hmkfn(unpack(hargs)))
        end
        mixin[mname] = { fn = basefn, sandboxfn = sandboxbasefn, incheck = incheck, outcheck = outcheck }
      end
      uiobjects[name] = {
        cfg = cfg,
        constructor = constructor,
        inherits = cfg.inherits,
        mixin = mixin,
        scripts = cfg.scripts,
      }
    end
    return flatten(uiobjects)
  end
end
