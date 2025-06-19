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
        sandboxIndex[n] = debug.newcfunction(bubblewrap(function(obj, ...)
          return f(api.UserData(obj), ...)
        end))
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

  local function wrapstrfn(s, fname, args, ...)
    local wrapstr = ('local %s=...;%s'):format(args, s)
    local wrapfn = assert(loadstring(wrapstr, fname))
    setfenv(wrapfn, _G)
    return wrapfn(...)
  end

  local typechecker = require('wowless.typecheck')(api)
  local funchecker = require('wowless.funcheck')(typechecker)

  local function check(spec, v)
    local vv, errmsg = typechecker(spec, v)
    return errmsg and error(errmsg) or vv
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
        local doCheckOutputs = funchecker.makeCheckOutputs(fname, method)
        return function(...)
          return doCheckOutputs(fn(...))
        end
      end
      local mtext = method.impl or method
      local src = method.src and ('@' .. method.src) or fname
      local fn = assert(loadstring(mtext, src))(api, toTexture, check, stubMixin)
      mixin[mname] = checkOutputs(checkInputs(wrap(mname, fn)))
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
