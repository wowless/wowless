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
        local hostindex = {}
        local sandboxindex = {}
        for inh in pairs(ty.inherits) do
          flattenOne(inh)
          local r = result[string.lower(inh)]
          Mixin(isa, r.isa)
          Mixin(scripts, r.scripts)
          Mixin(hostindex, r.hostindex)
          Mixin(sandboxindex, r.sandboxindex)
        end
        for n, m in pairs(ty.mixin) do -- do this last in case of overrides
          hostindex[n] = m.hostfn
          sandboxindex[n] = m.sandboxDispatch
        end
        result[lk] = {
          constructor = ty.constructor,
          ctype = ty.cfg.uitype_bit,
          hostindex = hostindex,
          isa = isa,
          name = ty.cfg.objectType or k,
          sandboxindex = sandboxindex,
          scripts = scripts,
        }
      end
    end
    for k in pairs(types) do
      flattenOne(k)
    end
    local t = {}
    for k, v in pairs(result) do
      local sandboxMTindex = {}
      for n, fn in pairs(v.sandboxindex) do
        sandboxMTindex[n] = bubblewrap(fn)
      end
      t[k] = {
        constructor = v.constructor,
        ctype = v.ctype,
        hostMT = { __index = v.hostindex }, -- issue #657
        isa = v.isa,
        name = v.name,
        sandboxMT = { __index = sandboxMTindex },
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
        local hostfn = wrap(fname, mkfn(unpack(args)))
        local sandboxDispatch
        if method.sandboximpl then
          local sbmkfn = assert(loadstring_untainted(method.sandboximpl, src), fname)
          local sbargs = {}
          for _, sm in ipairs(method.sandboxmodules or {}) do
            table.insert(sbargs, (assert(modules[sm], sm)))
          end
          local sbfn = wrap(fname, sbmkfn(unpack(sbargs)))
          sandboxDispatch = function(obj, ...)
            return sbfn(UserData(obj), ...)
          end
        else
          local sandboxfn
          if not incheck and not outcheck then
            sandboxfn = hostfn
          elseif not incheck then
            sandboxfn = function(...)
              return outcheck(hostfn(...))
            end
          elseif not outcheck then
            sandboxfn = function(self, ...)
              return hostfn(self, incheck(...))
            end
          else
            sandboxfn = function(self, ...)
              return outcheck(hostfn(self, incheck(...)))
            end
          end
          sandboxDispatch = function(obj, ...)
            return sandboxfn(UserData(obj), ...)
          end
        end
        mixin[mname] = { hostfn = hostfn, sandboxDispatch = sandboxDispatch }
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
