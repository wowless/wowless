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

  local function resolveobj(ty, value, isout)
    if isout then
      if value and value.luarep then
        return value.luarep, not value:IsObjectType(ty)
      else
        return nil, true
      end
    else
      if ty == 'Font' and type(value) == 'string' then
        value = api.env[value]
      end
      if type(value) ~= 'table' then
        return nil, true
      end
      local ud = api.UserData(value)
      return ud, not ud or not ud:IsObjectType(ty)
    end
  end

  local plainscalartypechecks = {
    boolean = function(value, isout)
      if isout then
        return value, type(value) ~= 'boolean'
      else
        return not not value
      end
    end,
    gender = function(value)
      return tonumber(value) or 0
    end,
    ['function'] = function(value)
      return luatypecheck('function', value)
    end,
    number = function(value, isout)
      if isout then
        return luatypecheck('number', value)
      else
        return luatypecheck('number', type(value) == 'string' and tonumber(value) or value)
      end
    end,
    oneornil = function(value)
      return value, value ~= 1
    end,
    string = function(value, isout)
      if isout then
        return luatypecheck('string', value)
      else
        return luatypecheck('string', type(value) == 'number' and tostring(value) or value)
      end
    end,
    table = function(value)
      return luatypecheck('table', value)
    end,
    tonumber = function(value)
      local v = type(value) == 'string' and tonumber(value) or value
      return type(v) == 'number' and v or nil
    end,
    tostring = function(value)
      local v = type(value) == 'number' and tostring(value) or value
      return type(v) == 'string' and v or nil
    end,
    uiAddon = function(value)
      return api.addons[tonumber(value) or tostring(value):lower()]
    end,
    unit = function(value)
      if type(value) ~= 'string' then
        return nil, true
      end
      return api.modules.units.GetUnit(value)
    end,
    unknown = function(value)
      return value
    end,
    userdata = function(value)
      return luatypecheck('userdata', value)
    end,
  }

  local function plainmismatch(typename, value)
    return nil, ('is of type %q, but %q was passed'):format(typename, type(value))
  end

  local function mismatch(spec, value)
    return plainmismatch(typestr(spec.type), value)
  end

  local scalartypechecks = {}
  for checktype, checkfn in pairs(plainscalartypechecks) do
    assert(not scalartypechecks[checktype])
    scalartypechecks[checktype] = function(value, isout)
      local v, err = checkfn(value, isout)
      if err then
        return plainmismatch(checktype, v)
      else
        return v
      end
    end
  end
  for etype, evalues in pairs(require('runtime.stringenums')) do
    assert(not scalartypechecks[etype])
    scalartypechecks[etype] = function(value)
      if type(value) ~= 'string' then
        return plainmismatch(etype, value)
      end
      value = value:upper()
      if not evalues[value] then
        return nil, ('is of type %q, which does not have value %q'):format(etype, value)
      end
      return value
    end
  end
  for k in pairs(api.datalua.uiobjects) do
    assert(not scalartypechecks[k])
    scalartypechecks[k] = function(value, isout)
      local v, err = resolveobj(k, value, isout)
      if err then
        return plainmismatch(k, v)
      else
        return v
      end
    end
  end

  local nilables = {
    gender = true,
    ['nil'] = true,
    oneornil = true,
  }

  local typecheck

  local function dotypecheck(spec, value, isout)
    local scalartypecheck = scalartypechecks[spec.type]
    if scalartypecheck then
      return scalartypecheck(value, isout)
    end
    if spec.type.enum then
      local v = type(value) == 'string' and tonumber(value) or value
      if type(v) ~= 'number' then
        return mismatch(spec, value)
      end
      -- TODO handle flag-style enums more intelligently than this
      if spec.type.enum:sub(-4) == 'Flag' then
        return v
      end
      if not enumrev[spec.type.enum][v] then
        return v, ('is of enum type %q, which does not have value %d'):format(spec.type.enum, v), true
      end
      return v
    elseif spec.type.structure then
      if type(value) ~= 'table' then
        return mismatch(spec, value)
      end
      local st = api.datalua.structures[spec.type.structure]
      for fname, fspec in pairs(st.fields) do
        local _, err = typecheck(fspec, value[fname], isout)
        if err then
          return nil, 'field ' .. fname .. ' ' .. err
        end
      end
      if isout then
        local m = st.mixin and api.env[st.mixin] or {}
        for k, v in pairs(m) do
          if value[k] ~= v then
            return nil, 'has incorrect mixin value ' .. k
          end
        end
        for k in pairs(value) do
          if not st.fields[k] and not m[k] then
            return nil, 'has extraneous field ' .. k
          end
        end
      end
      return value
    elseif spec.type.arrayof then
      if type(value) ~= 'table' then
        return mismatch(spec, value)
      end
      local espec = { type = spec.type.arrayof }
      for i, v in ipairs(value) do
        local _, err = typecheck(espec, v, isout)
        if err then
          return nil, 'element ' .. i .. ' ' .. err
        end
      end
      if isout then
        local n = 0
        for _ in pairs(value) do
          n = n + 1
        end
        if #value ~= n then
          return nil, 'is not strictly an array'
        end
      end
      return value
    else
      return nil, 'invalid spec'
    end
  end

  function typecheck(spec, value, isout)
    if value == nil then
      if spec.default ~= nil then
        return spec.default
      end
      if not spec.nilable and not nilables[spec.type] then
        return nil, 'is not nilable, but nil was passed'
      end
      return nil
    end
    local val, msg, warn = dotypecheck(spec, value, isout)
    if msg and spec.permissive then
      return spec.default
    end
    return val, msg, warn
  end

  return typecheck
end
