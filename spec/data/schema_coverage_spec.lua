local wdata = require('wowapi.data')

local function collectType(st, path, known, visited)
  if type(st) == 'string' then
    return
  end
  local k, v = next(st)
  if k == 'record' then
    for fname in pairs(v) do
      known[path .. '.' .. fname] = true
      collectType(v[fname].type, path .. '.' .. fname, known, visited)
    end
  elseif k == 'taggedunion' then
    for mname, mval in pairs(v) do
      known[path .. '.' .. mname] = true
      if mval ~= 'tag' then
        collectType(mval, path .. '.' .. mname, known, visited)
      end
    end
  elseif k == 'mapof' then
    collectType(v.key, path .. '.__key', known, visited)
    collectType(v.value, path .. '.__val', known, visited)
  elseif k == 'sequenceof' or k == 'setof' then
    collectType(v, path .. '.__elem', known, visited)
  elseif k == 'schema' then
    if not visited[v] then
      visited[v] = true
      local s = wdata.schemas[v]
      if s then
        collectType(s.type, v, known, visited)
      end
    end
  end
  -- ref and literal are leaves with no fields/members to collect
end

local function trackType(st, value, path, used)
  if type(st) == 'string' then
    return
  end
  local k, v = next(st)
  if k == 'record' then
    if type(value) ~= 'table' then
      return
    end
    for fname, fval in pairs(value) do
      if v[fname] then
        used[path .. '.' .. fname] = true
        trackType(v[fname].type, fval, path .. '.' .. fname, used)
      end
    end
  elseif k == 'taggedunion' then
    if type(value) == 'string' then
      if v[value] == 'tag' then
        used[path .. '.' .. value] = true
      end
    elseif type(value) == 'table' then
      local vk, vv = next(value)
      if vk and v[vk] then
        used[path .. '.' .. vk] = true
        if v[vk] ~= 'tag' then
          trackType(v[vk], vv, path .. '.' .. vk, used)
        end
      end
    end
  elseif k == 'mapof' then
    if type(value) == 'table' then
      for mk, mv in pairs(value) do
        trackType(v.key, mk, path .. '.__key', used)
        trackType(v.value, mv, path .. '.__val', used)
      end
    end
  elseif k == 'sequenceof' then
    if type(value) == 'table' then
      for _, sv in ipairs(value) do
        trackType(v, sv, path .. '.__elem', used)
      end
    end
  elseif k == 'setof' then
    if type(value) == 'table' then
      for sk in pairs(value) do
        trackType(v, sk, path .. '.__elem', used)
      end
    end
  elseif k == 'schema' then
    local s = wdata.schemas[v]
    if s then
      trackType(s.type, value, v, used)
    end
  end
  -- ref and literal are leaves
end

-- Schemas for external data formats (not our YAML data files) are excluded.
local externalSchemas = {
  doctable = true,
}

local known = {}
do
  local visited = {}
  for name in pairs(wdata.schemas) do
    if not visited[name] and not externalSchemas[name] then
      visited[name] = true
      collectType(wdata.schemas[name].type, name, known, visited)
    end
  end
end

local used = {}
local products = require('build.data.products')

trackType(wdata.schemas.datafiles.type, wdata.datafiles, 'datafiles', used)

for name, dtype in pairs(wdata.datafiles) do
  if dtype == 'global' then
    trackType(wdata.schemas[name].type, wdata[name], name, used)
  elseif dtype == 'product' then
    for _, p in ipairs(products) do
      trackType(wdata.schemas[name].type, wdata[name][p], name, used)
    end
  end
end

-- Schema files themselves are data validated against the 'schema' schema
local schemaSchemaType = wdata.schemas.schema.type
for _, s in pairs(wdata.schemas) do
  trackType(schemaSchemaType, s, 'schema', used)
end

describe('schema coverage', function()
  for path in pairs(known) do
    it(path, function()
      assert.True(used[path] == true)
    end)
  end
end)
