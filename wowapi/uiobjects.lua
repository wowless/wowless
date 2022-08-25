local util = require('wowless.util')
local Mixin = util.mixin

local function toTexture(parent, tex, obj)
  if type(tex) == 'string' or type(tex) == 'number' then
    local t = obj or parent:CreateTexture()
    t:SetTexture(tex)
    return t
  else
    return tex
  end
end

local function mkBaseUIObjectTypes(api, loader)
  local log = api.log or function() end

  local function u(x)
    return api.UserData(x)
  end

  local function m(obj, f, ...)
    return getmetatable(obj).__index[f](obj, ...)
  end

  local function nextkid(obj, kid)
    local ud = u(obj)
    local set = ud.childrenSet
    if set then
      local list = assert(ud.childrenList)
      local idx = 0
      if kid then
        idx = assert(set[kid])
        assert(list[idx] == kid)
      end
      while idx < #list do
        idx = idx + 1
        kid = list[idx]
        if set[kid] == idx then
          return kid
        end
      end
    end
  end

  local function kids(obj)
    return nextkid, obj, nil
  end

  local function DoUpdateVisible(obj, script)
    for kid in kids(obj) do
      if u(kid).shown then
        DoUpdateVisible(kid, script)
      end
    end
    api.RunScript(obj, script)
  end

  local function UpdateVisible(obj, fn)
    log(4, 'enter UpdateVisible(%s)', api.GetDebugName(obj))
    local wasVisible = m(obj, 'IsVisible')
    fn()
    local visibleNow = m(obj, 'IsVisible')
    if wasVisible ~= visibleNow then
      DoUpdateVisible(obj, visibleNow and 'OnShow' or 'OnHide')
    end
    log(4, 'leave UpdateVisible(%s)', api.GetDebugName(obj))
  end

  local function flatten(types)
    local result = {}
    local function flattenOne(k)
      local lk = string.lower(k)
      if not result[lk] then
        local ty = types[k]
        local inherits = {}
        local metaindex = Mixin({}, ty.mixin)
        for _, inh in ipairs(ty.inherits) do
          flattenOne(inh)
          table.insert(inherits, string.lower(inh))
          for mk, mv in pairs(result[string.lower(inh)].metatable.__index) do
            assert(not metaindex[mk] or metaindex[mk] == mv, 'multiple implementations of ' .. mk)
            metaindex[mk] = mv
          end
        end
        result[lk] = {
          constructor = function(self)
            for _, inh in ipairs(inherits) do
              result[inh].constructor(self)
            end
            if ty.constructor then
              ty.constructor(self)
            end
          end,
          inherits = inherits,
          metatable = { __index = metaindex },
          name = ty.cfg.objectType or k,
        }
      end
    end
    for k in pairs(types) do
      flattenOne(k)
    end
    for _, v in pairs(result) do
      local t = v.metatable.__index
      for k, f in pairs(t) do
        t[k] = debug.newcfunction(f)
      end
    end
    return result
  end

  local datalua = require('build.products.' .. loader.product .. '.data')

  local env = {
    api = api,
    build = datalua.build,
    kids = kids,
    m = m,
    toTexture = toTexture,
    u = u,
    UpdateVisible = UpdateVisible,
  }
  for k, v in pairs(_G) do
    env[k] = v
  end

  local uiobjects = {}
  for name, cfg in pairs(datalua.uiobjects) do
    local lname = name:lower()
    local function wrap(fname, fn)
      setfenv(fn, env)
      return function(self, ...)
        if not api.InheritsFrom(u(self).type, lname) then
          error(('invalid self to %s.%s, got %s'):format(name, fname, tostring(u(self).type)))
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
    local constructor = (function()
      local deepcopy = require('pl.tablex').deepcopy
      return function(self)
        local ud = u(self)
        for fname, field in pairs(cfg.fields or {}) do
          if field.init ~= nil then
            ud[fname] = type(field.init) == 'table' and deepcopy(field.init) or field.init
          end
        end
      end
    end)()
    local mixin = {}
    for mname, method in pairs(cfg.methods) do
      if method.status == 'implemented' then
        mixin[mname] = assert(loadstring(method.impl), ('function required on %s.%s'):format(name, mname))
      elseif method.status == 'getter' then
        mixin[mname] = function(self)
          local ud = u(self)
          local t = {}
          for i, f in ipairs(method.fields) do
            t[i] = ud[f.name]
          end
          return unpack(t, 1, #method.fields)
        end
      elseif method.status == 'setter' then
        mixin[mname] = function(self, ...)
          local n = select('#', ...)
          local ud = u(self)
          for i, f in ipairs(method.fields) do
            local v = select(i, ...)
            local cf = cfg.fields[f.name]
            local ty = cf.type
            if ty == 'boolean' then
              ud[f.name] = not not v
            elseif i > n then
              assert(not f.required, ('value required on %s.%s.%s'):format(name, mname, f.name))
            elseif v == nil then
              assert(f.nilable or cf.nilable, ('cannot set nil on %s.%s.%s'):format(name, mname, f.name))
              ud[f.name] = nil
            elseif ty == 'texture' then
              ud[f.name] = toTexture(self, v)
            elseif ty == 'number' then
              ud[f.name] = assert(tonumber(v), ('want number, got %s'):format(type(v)))
            elseif ty == 'string' then
              ud[f.name] = tostring(v)
            elseif ty == 'font' then
              if type(v) == 'string' then
                v = api.env[v]
              end
              assert(type(v) == 'table', 'expected font')
              ud[f.name] = v
            elseif ty == 'frame' then
              if type(v) == 'string' then
                v = api.env[v]
              end
              assert(api.InheritsFrom(v:GetObjectType():lower(), 'frame'))
              ud[f.name] = v
            elseif ty == 'table' then
              assert(type(v) == 'table', 'expected table, got ' .. type(v))
              ud[f.name] = v
            else
              error('unexpected type ' .. ty)
            end
          end
        end
      elseif method.status == 'unimplemented' then
        -- TODO unify this with loader.lua
        local t = {}
        local n = method.outputs and #method.outputs or 0
        for _, output in ipairs(method.outputs or {}) do
          assert(output.type == 'number', ('unsupported type in %s.%s'):format(name, mname))
          table.insert(t, 1)
        end
        mixin[mname] = function()
          return unpack(t, 1, n)
        end
      else
        error(('unsupported method status %q on %s.%s'):format(method.status, name, mname))
      end
    end
    uiobjects[name] = {
      cfg = cfg,
      constructor = wrap('<init>', constructor),
      inherits = cfg.inherits,
      mixin = wrapAll(mixin),
    }
  end
  return flatten(uiobjects)
end

return mkBaseUIObjectTypes
