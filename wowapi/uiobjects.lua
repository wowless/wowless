local util = require('wowless.util')
local bubblewrap = require('wowless.bubblewrap')
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
          return f(api.UserData(obj), ...)
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

  local typechecker = require('wowless.typecheck')(api)
  local funchecker = require('wowless.funcheck')(typechecker, api.log)

  local function check(spec, v, isout)
    local vv, errmsg = typechecker(spec, v, isout)
    return errmsg and error(errmsg, 2) or vv
  end

  local function stubMixin(t, name)
    return Mixin(t, api.env[name])
  end

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
      local incheck = method.inputs and funchecker.makeCheckInputs(fname, method)
      local outcheck = method.outputs and funchecker.makeCheckOutputs(fname, method)
      local mtext = method.impl or method
      local src = method.src and ('@' .. method.src) or fname
      local fn = assert(loadstring_untainted(mtext, src))(api, toTexture, check, stubMixin)
      local basefn = wrap(fname, fn)
      local outfn
      if not incheck and not outcheck then
        outfn = basefn
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

return mkBaseUIObjectTypes
