local util = require('wowless.util')
local Mixin = util.mixin
local hlist = require('wowless.hlist')

local function toTexture(parent, tex, obj)
  if type(tex) == 'string' or type(tex) == 'number' then
    local t = obj or parent:CreateTexture()
    t:SetTexture(tex)
    return t
  else
    return tex
  end
end

local function mkBaseUIObjectTypes(api)
  local u = api.UserData

  local function DoUpdateVisible(obj, script)
    for kid in obj.children:entries() do
      if kid.shown then
        DoUpdateVisible(kid, script)
      end
    end
    api.RunScript(obj, script)
  end

  local function UpdateVisible(obj, fn)
    local wasVisible = obj:IsVisible()
    fn()
    local visibleNow = obj:IsVisible()
    if wasVisible ~= visibleNow then
      DoUpdateVisible(obj, visibleNow and 'OnShow' or 'OnHide')
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
          zombie = ty.cfg.zombie,
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
          return f(u(obj), ...)
        end)
      end
      t[k] = {
        constructor = v.constructor,
        hostMT = { __index = v.metaindex },
        isa = v.isa,
        name = v.name,
        sandboxMT = { __index = sandboxIndex },
        zombie = v.zombie,
      }
    end
    return t
  end

  local env = {
    api = api,
    build = api.datalua.build,
    toTexture = toTexture,
    u = u,
    UpdateVisible = UpdateVisible,
  }
  for k, v in pairs(_G) do
    env[k] = v
  end

  local constructorEnv = {
    hlist = hlist,
  }

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
    local function wrapAll(map)
      local mm = {}
      for k, v in pairs(map) do
        mm[k] = wrap(k, v)
      end
      return mm
    end
    local constructor = setfenv(assert(loadstring(cfg.constructor)), constructorEnv)
    local mixin = {}
    for mname, method in pairs(cfg.methods) do
      local fname = name .. ':' .. mname
      if method.impl then
        local impl = assert(loadstring(method.impl, fname), 'function required on ' .. fname)
        setfenv(impl, env)
        mixin[mname] = impl
      else
        assert(method.fields, 'missing fields on ' .. fname)
        mixin[mname] = function(self, ...)
          for i, f in ipairs(method.fields) do
            local v = select(i, ...)
            local cf = cfg.fields[f.name]
            local ty = cf.type
            if ty == 'boolean' then
              self[f.name] = not not v
            elseif v == nil then
              assert(f.nilable or cf.nilable, ('cannot set nil on %s.%s.%s'):format(name, mname, f.name))
              self[f.name] = nil
            elseif ty == 'texture' then
              self[f.name] = toTexture(self, v)
            elseif ty == 'number' then
              self[f.name] = assert(tonumber(v), ('want number, got %s'):format(type(v)))
            elseif ty == 'string' then
              self[f.name] = tostring(v)
            elseif ty == 'font' then
              if type(v) == 'string' then
                v = api.env[v]
              end
              assert(type(v) == 'table', 'expected font')
              self[f.name] = v
            elseif ty == 'frame' then
              if type(v) == 'string' then
                v = api.env[v]
              end
              assert(api.InheritsFrom(v:GetObjectType():lower(), 'frame'))
              self[f.name] = v
            elseif ty == 'table' then
              assert(type(v) == 'table', 'expected table, got ' .. type(v))
              self[f.name] = v
            else
              error('unexpected type ' .. ty)
            end
          end
        end
      end
    end
    uiobjects[name] = {
      cfg = cfg,
      constructor = constructor,
      inherits = cfg.inherits,
      mixin = wrapAll(mixin),
    }
  end
  return flatten(uiobjects)
end

return mkBaseUIObjectTypes
