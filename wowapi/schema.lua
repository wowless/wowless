local wdata = require('wowapi.data')

-- Domain names used by the 'ref' schematype match data/datafiles.yaml keys,
-- so global-vs-product is looked up there. A few domains aren't declared in
-- datafiles.yaml because they aren't simple per-file loads (see
-- wowapi/data.lua):
--  - 'schemas' is assembled from the data/schemas directory
--  - 'enums' is extracted from each product's globals.yaml
--  - 'domains' is the set of valid domain names itself, letting
--    schematype.yaml check that a schema's ref.schema field names a real
--    domain without separately enumerating them
local domainnames = {}
for name in pairs(wdata.datafiles) do
  domainnames[name] = true
end

local extradomains = {
  schemas = { kind = 'global', domain = wdata.schemas },
  enums = { kind = 'product', domain = wdata.enums },
  domains = { kind = 'global', domain = domainnames },
}
for name in pairs(extradomains) do
  domainnames[name] = true
end

local function mksimple(ty)
  return function(v)
    local vty = type(v)
    if vty ~= ty then
      return ('want %s, got %s'):format(ty, vty)
    end
  end
end

local simple = {
  any = function() end,
  boolean = mksimple('boolean'),
  flag = function(v)
    if v ~= true then
      local vty = type(v)
      local suffix = vty == 'boolean' and ' (false)' or ''
      return ('want flag (boolean true), got %s%s'):format(vty, suffix)
    end
  end,
  number = mksimple('number'),
  string = mksimple('string'),
  table = mksimple('table'),
}

local compile

local schemas = {}

local complex = {
  hierarchy = function(s)
    local of = compile({ mapof = { key = 'string', value = { record = s.fields } } })
    local parentfield = s.parent
    local function parentsof(node)
      if type(node) ~= 'table' then
        return {}
      end
      local p = node[parentfield]
      if p == nil then
        return {}
      elseif type(p) == 'string' then
        return { p }
      end
      local ps = {}
      for pk in pairs(p) do
        ps[#ps + 1] = pk
      end
      return ps
    end
    return function(v, product)
      local baseerrors = of(v, product)
      if type(v) ~= 'table' then
        return baseerrors
      end
      local errors = baseerrors or {}
      local function shapeerror(root, k, seen)
        if seen[k] then
          return ('multiple paths from %s to %s'):format(root, k)
        end
        seen[k] = true
        for _, p in ipairs(parentsof(v[k])) do
          local e = shapeerror(root, p, seen)
          if e then
            return e
          end
        end
      end
      local function ancestorsof(k, seen)
        for _, p in ipairs(parentsof(v[k])) do
          if not seen[p] then
            seen[p] = true
            ancestorsof(p, seen)
          end
        end
        return seen
      end
      for k, node in pairs(v) do
        local e = shapeerror(k, k, {})
        if e then
          errors[k] = e
        else
          local anc = ancestorsof(k, {})
          for f in pairs(s.unique) do
            local mine = node[f]
            if type(mine) == 'table' then
              for ik in pairs(mine) do
                for a in pairs(anc) do
                  local an = v[a]
                  if an and type(an[f]) == 'table' and an[f][ik] ~= nil then
                    errors[k] = errors[k] or {}
                    errors[k][f] = ('%s already defined by ancestor %s'):format(ik, a)
                  end
                end
              end
            end
          end
        end
      end
      return next(errors) and errors or nil
    end
  end,
  literal = function(s)
    return function(v)
      if v ~= s then
        return 'string literal mismatch'
      end
    end
  end,
  mapof = function(s)
    local key = compile(s.key)
    local value = compile(s.value)
    return function(v, product)
      if type(v) ~= 'table' then
        return 'expected table'
      end
      local errors = {}
      for vk, vv in pairs(v) do
        local ek = key(vk, product)
        local ev = value(vv, product)
        if ek or ev then
          errors[vk] = { key = ek, value = ev }
        end
      end
      return next(errors) and errors or nil
    end
  end,
  record = function(s)
    local fields = {}
    local required = {}
    for k, v in pairs(s) do
      fields[k] = compile(v.type)
      required[k] = v.required or nil
    end
    return function(v, product)
      if type(v) ~= 'table' then
        return 'expected table'
      end
      local errors = {}
      for vk, vv in pairs(v) do
        local field = fields[vk]
        errors[vk] = not field and 'unknown field' or field(vv, product)
      end
      for k in pairs(required) do
        if v[k] == nil then
          errors[k] = 'missing required field'
        end
      end
      return next(errors) and errors or nil
    end
  end,
  ref = function(s)
    local extra = extradomains[s.schema]
    local kind, domain
    if extra then
      kind, domain = extra.kind, extra.domain
    elseif wdata.datafiles[s.schema] then
      kind, domain = wdata.datafiles[s.schema], wdata[s.schema]
    end
    local mustexist = not s.negative
    return function(v, product)
      if type(v) ~= 'string' then
        return 'expected string'
      end
      if not domain then
        return 'invalid domain'
      end
      local d = kind == 'global' and domain or domain[product]
      if not d then
        return 'invalid domain'
      end
      if (d[v] ~= nil) ~= mustexist then
        return (mustexist and 'unknown' or 'known') .. ' domain value'
      end
    end
  end,
  schema = function(s)
    local schema = wdata.schemas[s]
    if not schema then
      error('bad schema: ' .. s)
    end
    return function(v, product)
      local fn = schemas[s]
      if not fn then
        -- We have to handle schema refs lazily to support circular refs.
        fn = compile(schema.type)
        schemas[s] = fn
      end
      return fn(v, product)
    end
  end,
  sequenceof = function(s)
    local element = compile(s)
    return function(v, product)
      if type(v) ~= 'table' then
        return 'expected table'
      end
      local errors = {}
      local max = 0
      for vk, vv in pairs(v) do
        if type(vk) ~= 'number' then
          errors[vk] = 'expected number'
        else
          max = vk > max and vk or max
          errors[vk] = element(vv, product)
        end
      end
      return max ~= #v and 'expected array' or next(errors) and errors or nil
    end
  end,
  setof = function(s)
    local element = compile(s)
    return function(v, product)
      if type(v) ~= 'table' then
        return 'expected table'
      end
      local errors = {}
      for vk, vv in pairs(v) do
        local ek = element(vk, product)
        local ev = (type(vv) ~= 'table' or next(vv)) and 'bad value' or nil
        if ek or ev then
          errors[vk] = { key = ek, value = ev }
        end
      end
      return next(errors) and errors or nil
    end
  end,
  taggedunion = function(s)
    local sf = {}
    local tf = {}
    local ks = {}
    for k, v in pairs(s) do
      if v == 'tag' then
        sf[k] = true
      else
        tf[k] = compile(v)
      end
      table.insert(ks, k)
    end
    table.sort(ks)
    local err = 'expected one of {' .. table.concat(ks, ', ') .. '}'
    return function(v, product)
      if sf[v] then
        return
      end
      if type(v) ~= 'table' then
        return err
      end
      local vk, vv = next(v)
      if vk == nil then
        return 'missing element, ' .. err
      end
      if next(v, vk) ~= nil then
        return 'multiple elements, ' .. err
      end
      local tfvk = tf[vk]
      if tfvk == nil then
        return 'bad key, ' .. err
      end
      return tfvk(vv, product)
    end
  end,
}

local function docompile(schematype)
  if type(schematype) ~= 'table' then
    error('unexpected schema type ' .. type(schematype))
  end
  local k, v = next(schematype)
  if next(schematype, k) then
    error('multiple keys in schematype')
  end
  return assert(complex[k], 'unknown complex schematype')(v)
end

function compile(schematype)
  return simple[schematype] or docompile(schematype)
end

local function validate(product, schematype, v)
  local errors = compile(schematype)(v, product)
  if errors then
    error(errors, 0)
  end
end

return {
  validate = validate,
}
