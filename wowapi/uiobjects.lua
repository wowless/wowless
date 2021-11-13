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

local function mkBaseUIObjectTypes(api, loader)
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
    local ud = u(obj)
    local pv = not ud.parent or u(ud.parent).visible
    local nv = pv and ud.shown
    if ud.visible ~= nv then
      ud.visible = nv
      api.RunScript(obj, nv and 'OnShow' or 'OnHide')
      for kid in kids(obj) do
        UpdateVisible(kid)
      end
    end
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
    loader = loader,
    m = m,
    STUB_NUMBER = function() return 1 end,
    toTexture = toTexture,
    u = u,
    UNIMPLEMENTED = function() end,
    UpdateVisible = UpdateVisible,
    util = require('wowless.util'),
  }
  for k, v in pairs(_G) do
    env[k] = v
  end

  local t = {}
  for k, v in pairs(require('wowapi.data').uiobjects) do
    t[k] = setfenv(v, env)()
  end
  return flatten(t)
end

return mkBaseUIObjectTypes
