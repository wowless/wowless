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

  local function m(obj, f, ...)
    return getmetatable(obj).__index[f](obj, ...)
  end

  local function DoUpdateVisible(obj, script)
    for kid in obj.children:entries() do
      if kid.shown then
        DoUpdateVisible(kid, script)
      end
    end
    api.RunScript(obj, script)
  end

  local function UpdateVisible(obj, fn)
    local wasVisible = m(obj, 'IsVisible')
    fn()
    local visibleNow = m(obj, 'IsVisible')
    if wasVisible ~= visibleNow then
      DoUpdateVisible(u(obj), visibleNow and 'OnShow' or 'OnHide')
    end
  end

  local function flatten(types)
    local result = {}
    local function flattenOne(k)
      local lk = string.lower(k)
      if not result[lk] then
        local ty = types[k]
        local inherits = {}
        local isa = { [lk] = true }
        local metaindex = Mixin({}, ty.mixin)
        for inh in pairs(ty.inherits) do
          flattenOne(inh)
          table.insert(inherits, string.lower(inh))
          Mixin(isa, result[string.lower(inh)].isa)
          for mk, mv in pairs(result[string.lower(inh)].metaindex) do
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
      local hostIndex = {}
      local sandboxIndex = {}
      for n, f in pairs(v.metaindex) do
        hostIndex[n] = function(obj, ...)
          return f(obj.luarep, ...)
        end
        sandboxIndex[n] = debug.newcfunction(f)
      end
      t[k] = {
        constructor = v.constructor,
        hostMT = { __index = hostIndex },
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
    m = m,
    toTexture = toTexture,
    u = u,
    UpdateVisible = UpdateVisible,
  }
  for k, v in pairs(_G) do
    env[k] = v
  end

  local uiobjects = {}
  for name, cfg in pairs(api.datalua.uiobjects) do
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
          elseif field.type == 'hlist' then
            ud[fname] = hlist()
          end
        end
      end
    end)()
    local mixin = {}
    for mname, method in pairs(cfg.methods) do
      local fname = name .. ':' .. mname
      if method.status == 'implemented' then
        mixin[mname] = assert(loadstring(method.impl, fname), 'function required on ' .. fname)
      elseif method.status == 'getter' then
        local t = {}
        for _, f in ipairs(method.fields) do
          table.insert(t, 'x.' .. f.name)
        end
        local src = 'function(x) x=u(x);return ' .. table.concat(t, ',') .. ' end'
        src = 'local u = ...;return ' .. src
        mixin[mname] = assert(loadstring(src, fname))(u)
      elseif method.status == 'setter' then
        mixin[mname] = function(self, ...)
          local ud = u(self)
          for i, f in ipairs(method.fields) do
            local v = select(i, ...)
            local cf = cfg.fields[f.name]
            local ty = cf.type
            if ty == 'boolean' then
              ud[f.name] = not not v
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
      elseif not method.status then
        -- TODO unify this with loader.lua
        local t = {}
        for _, output in ipairs(method.outputs or {}) do
          assert(output.type == 'number', 'unsupported type in ' .. fname)
          table.insert(t, 1)
        end
        mixin[mname] = loadstring('return ' .. table.concat(t, ', '), fname)
      else
        error(('unsupported method status %q on %s'):format(method.status, fname))
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
