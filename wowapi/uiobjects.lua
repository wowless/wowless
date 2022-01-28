local util = require('wowless.util')
local Mixin = util.mixin

local function toTexture(parent, tex)
  if type(tex) == 'string' or type(tex) == 'number' then
    local t = parent:CreateTexture()
    t:SetTexture(tex)
    return t
  else
    return tex
  end
end

local function mkBaseUIObjectTypes(api)
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

  local function UpdateVisible(obj)
    local shown = u(obj).shown
    log(4, 'enter UpdateVisible(%s) %s', api.GetDebugName(obj), tostring(shown))
    for kid in kids(obj) do
      if shown == u(kid).shown then
        UpdateVisible(kid)
      end
    end
    api.RunScript(obj, shown and 'OnShow' or 'OnHide')
    log(4, 'leave UpdateVisible(%s) %s', api.GetDebugName(obj), tostring(shown))
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
          Mixin(metaindex, result[string.lower(inh)].metatable.__index)
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
          name = k,
        }
      end
    end
    for k in pairs(types) do
      flattenOne(k)
    end
    return result
  end

  local env = {
    api = api,
    kids = kids,
    m = m,
    u = u,
    UpdateVisible = UpdateVisible,
    util = require('wowless.util'),
  }
  for k, v in pairs(_G) do
    env[k] = v
  end

  local uiobjects = {}
  for name, data in pairs(require('wowapi.data').uiobjects) do
    local function wrap(fname, fn)
      setfenv(fn, env)
      return function(self, ...)
        local dname = api.GetDebugName(self)
        dname = dname == "" and ("<" .. name .. ">") or dname
        log(4, 'entering %s:%s', dname, fname)
        local t = {...}
        local n = select('#', ...)
        return (function(success, ...)
          log(4, 'leaving %s:%s (%s)', dname, fname, success and 'success' or 'failure')
          assert(success, ...)
          return ...
        end)(pcall(function() return fn(self, unpack(t, 1, n)) end))
      end
    end
    local function wrapAll(map)
      local mm = {}
      for k, v in pairs(map) do
        mm[k] = wrap(k, v)
      end
      return mm
    end
    local cfg = data.cfg
    local lua = data.methods
    local constructor = (function()
      local deepcopy = require('pl.tablex').deepcopy
      return function(self)
        local ud = u(self)
        for fname, field in pairs(cfg.fields or {}) do
          if field.init then
            ud[fname] = type(field.init) == 'table' and deepcopy(field.init) or field.init
          end
        end
        if lua.init then
          setfenv(lua.init, getfenv(1))(self)
        end
      end
    end)()
    local mixin = {}
    for mname, method in pairs(cfg.methods) do
      if method.status == 'implemented' then
        mixin[mname] = assert(lua[mname])
      elseif method.status == 'getter' then
        mixin[mname] = function(self)
          local ud = u(self)
          local t = {}
          for i, f in ipairs(method.fields) do
            t[i] = ud[f]
          end
          return unpack(t, 1, #method.fields)
        end
      elseif method.status == 'setter' then
        mixin[mname] = function(self, ...)
          local ud = u(self)
          for i, f in ipairs(method.fields) do
            local v = select(i, ...)
            local ty = cfg.fields[f].type
            if ty == 'bool' then
              ud[f] = not not v
            elseif ty == 'texture' then
              ud[f] = toTexture(self, v)
            else
              ud[f] = v
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
        mixin[mname] = function() return unpack(t, 1, n) end
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
