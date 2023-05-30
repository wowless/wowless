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

  local function resolveobj(ty, value)
    if type(value) == 'string' then
      value = api.env[value]
    end
    if type(value) ~= 'table' then
      return nil, true
    end
    local ud = api.UserData(value)
    return ud, not ud or not ud:IsObjectType(ty)
  end

  local plainscalartypechecks = {
    boolean = function(value)
      return luatypecheck('boolean', value)
    end,
    gender = function(value)
      return tonumber(value) or 0
    end,
    font = function(value)
      return resolveobj('fontinstance', value)
    end,
    frame = function(value)
      return resolveobj('frame', value)
    end,
    ['function'] = function(value)
      return luatypecheck('function', value)
    end,
    number = function(value)
      return luatypecheck('number', type(value) == 'string' and tonumber(value) or value)
    end,
    oneornil = function(value)
      return value, value ~= 1
    end,
    string = function(value)
      return luatypecheck('string', type(value) == 'number' and tostring(value) or value)
    end,
    table = function(value)
      return luatypecheck('table', value)
    end,
    texture = function(value)
      return resolveobj('texture', value)
    end,
    tostring = function(value)
      local v = type(value) == 'number' and tostring(value) or value
      return type(v) == 'string' and v or nil
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
    scalartypechecks[checktype] = function(value)
      local v, err = checkfn(value)
      if err then
        return plainmismatch(checktype, v)
      else
        return v
      end
    end
  end
  for etype, evalues in pairs(require('build.data.stringenums')) do
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

  local nilables = {
    gender = true,
    ['nil'] = true,
    oneornil = true,
  }

  local function typecheck(spec, value)
    if value == nil then
      if not spec.nilable and spec.default == nil and not nilables[spec.type] then
        return nil, 'is not nilable, but nil was passed'
      end
      return nil
    end
    local scalartypecheck = scalartypechecks[spec.type]
    if scalartypecheck then
      return scalartypecheck(value)
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
        local _, err = typecheck(fspec, value[fname])
        if err then
          return nil, 'field ' .. fname .. ' ' .. err
        end
      end
      -- TODO assert presence of mixin
      return value
    elseif spec.type.arrayof then
      if type(value) ~= 'table' then
        return mismatch(spec, value)
      end
      local espec = { type = spec.type.arrayof }
      for i, v in ipairs(value) do
        local _, err = typecheck(espec, v)
        if err then
          return nil, 'element ' .. i .. ' ' .. err
        end
      end
      return value
    else
      return nil, 'invalid spec'
    end
  end

  return typecheck
end
