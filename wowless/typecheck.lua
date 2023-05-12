return function(api)
  local enumrev = {}
  for k, v in pairs(api.datalua.globals.Enum) do
    local t = {}
    for vk, vv in pairs(v) do
      t[vv] = vk
    end
    enumrev[k] = t
  end

  local function typestr(ty)
    if type(ty) == 'string' then
      return ty
    end
    if ty.structure then
      return ty.structure
    end
    if ty.arrayof then
      return typestr(ty.arrayof) .. ' array'
    end
    if ty.enum then
      return ty.enum
    end
    error('unable to typestr')
  end

  local function luatypecheck(basetype, value)
    return value, type(value) ~= basetype
  end

  local scalartypechecks = {
    boolean = function(value)
      return luatypecheck('boolean', value)
    end,
    ['function'] = function(value)
      return luatypecheck('function', value)
    end,
    number = function(value)
      return luatypecheck('number', type(value) == 'string' and tonumber(value) or value)
    end,
    string = function(value)
      return luatypecheck('string', type(value) == 'number' and tostring(value) or value)
    end,
    table = function(value)
      return luatypecheck('table', value)
    end,
    uiAddon = function(value)
      return api.states.Addons[tonumber(value) or tostring(value):lower()]
    end,
    unit = function(value)
      if type(value) ~= 'string' then
        return nil, true
      end
      -- TODO complete unit resolution
      local units = api.states.Units
      local guid = units.aliases[value:lower()]
      return guid and units.guids[guid] or nil
    end,
    unknown = function(_, value)
      return value
    end,
  }

  local function mismatch(spec, value)
    return nil, ('is of type %q, but %q was passed'):format(typestr(spec.type), type(value))
  end

  return function(spec, value)
    if value == nil then
      if not spec.nilable and spec.default == nil then
        return nil, 'is not nilable, but nil was passed'
      end
      return nil
    end
    local scalartypecheck = scalartypechecks[spec.type]
    if scalartypecheck then
      local v, err = scalartypecheck(value)
      if err then
        return mismatch(spec, value)
      else
        return v
      end
    end
    if spec.type.enum then
      local v = type(value) == 'string' and tonumber(value) or value
      if type(v) ~= 'number' then
        return mismatch(spec, value)
      end
      if not enumrev[spec.type.enum][v] then
        return v, ('is of enum type %q, which does not have value %d'):format(spec.type.enum, v), true
      end
      return v
    elseif spec.type.structure then
      -- TODO better structure checking
      if type(value) ~= 'table' then
        return mismatch(spec, value)
      end
      return value
    elseif spec.type.arrayof then
      -- TODO better array checking
      if type(value) ~= 'table' then
        return mismatch(spec, value)
      end
      return value
    else
      return nil, 'invalid spec'
    end
  end
end
