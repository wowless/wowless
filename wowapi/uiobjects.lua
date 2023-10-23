local util = require('wowless.util')
local Mixin = util.mixin
local hlist = require('wowless.hlist')

local function mkBaseUIObjectTypes(api)
  local function toTexture(parent, tex, obj)
    if type(tex) == 'string' or type(tex) == 'number' then
      local t = obj or api.UserData(parent:CreateTexture())
      t:SetTexture(tex)
      return t
    else
      return tex and api.UserData(tex)
    end
  end

  local function flatten(types)
    local result = {}
    local function flattenOne(k)
      local lk = string.lower(k)
      if not result[lk] then
        local ty = types[k]
        local isa = { [lk] = true }
        local metaindex = Mixin({}, ty.mixin)
        for inh in pairs(ty.inherits) do
          flattenOne(inh)
          Mixin(isa, result[string.lower(inh)].isa)
          for mk, mv in pairs(result[string.lower(inh)].metaindex) do
            assert(not metaindex[mk], 'multiple implementations of ' .. mk)
            metaindex[mk] = mv
          end
        end
        result[lk] = {
          constructor = ty.constructor,
          isa = isa,
          metaindex = metaindex,
          name = ty.cfg.objectType or k,
          warner = ty.cfg.warner,
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
        sandboxIndex[n] = debug.newcfunction(function(obj, ...)
          return f(api.UserData(obj), ...)
        end)
      end
      t[k] = {
        constructor = v.constructor,
        hostMT = { __index = v.metaindex },
        isa = v.isa,
        name = v.name,
        sandboxMT = { __index = sandboxIndex },
        warner = v.warner,
      }
    end
    return t
  end

  local function wrapstrfn(s, fname, args, ...)
    return assert(loadstring(('local %s=...;return %s'):format(args, s), fname))(...)
  end

  local typechecker = require('wowless.typecheck')(api)

  local check = setmetatable({
    Texture = function(v, self)
      return toTexture(self, v)
    end,
  }, {
    __index = function(t, k)
      local spec = { type = k }
      local fn = function(v)
        local vv, errmsg = typechecker(spec, v)
        return errmsg and error(errmsg) or vv
      end
      t[k] = fn
      return fn
    end,
  })

  local uiobjects = {}
  for name, cfg in pairs(api.datalua.uiobjects) do
    local lname = name:lower()
    local function wrap(fname, fn)
      return function(self, ...)
        if not api.InheritsFrom(self.type, lname) then
          error(('invalid self to %s.%s, got %s'):format(name, fname, tostring(self.type)))
        end
        return fn(self, ...)
      end
    end
    local constructor = wrapstrfn(cfg.constructor, name, 'hlist', hlist)
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
      local function checkInputs(fn)
        if not method.inputs then
          return fn
        end
        local sig = method.inputs
        local nsig = #method.inputs
        return function(self, ...)
          local args = {}
          for i, param in ipairs(sig) do
            local v, errmsg, iswarn = typechecker(param, (select(i, ...)))
            if not errmsg then
              args[i] = v
            else
              local msg = ('arg %d (%q) of %q %s'):format(i, tostring(param.name), fname, errmsg)
              if iswarn then
                api.log(1, 'warning: ' .. msg)
              else
                error(msg)
              end
            end
          end
          return fn(self, unpack(args, 1, nsig))
        end
      end
      local function checkOutputs(fn)
        if not method.outputs then
          return fn
        end
        local outs = method.outputs
        local nouts = #outs
        local mayreturnnothing = method.mayreturnnothing
        local function doCheckOutputs(...)
          local n = select('#', ...)
          if n == 0 and mayreturnnothing then
            return
          end
          if #outs ~= n then
            error(('wrong number of return values to %q: want %d, got %d'):format(fname, nouts, n))
          end
          local rets = {}
          for i, out in ipairs(outs) do
            local v, errmsg = typechecker(out, (select(i, ...)), true)
            if errmsg then
              error(('output %d (%q) of %q %s'):format(i, tostring(out.name), fname, errmsg))
            end
            rets[i] = v
          end
          return unpack(rets, 1, nouts)
        end
        return function(...)
          return doCheckOutputs(fn(...))
        end
      end
      local mtext = method.impl or method
      local fn = wrap(mname, wrapstrfn(mtext, fname, 'api,toTexture,check', api, toTexture, check))
      mixin[mname] = checkOutputs(checkInputs(fn))
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

return mkBaseUIObjectTypes
