local emitter = require('yaml').emitter
local parse = require('lyaml').load

local fieldOrder = {
  'name',
  'status',
  'comment',
  'versions',
  'inputs',
  'newinputs',
  'outputs',
  'mixin',
  'protected',
  'returns',
  'module',
  'api',
}

local function isarray(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then
      return false
    end
  end
  return true
end

local function keycomp(a, b)
  return a:lower() < b:lower()
end

local function api2yaml(api)
  local emit = emitter().emit
  assert(emit({type = 'STREAM_START'}))
  assert(emit({type = 'DOCUMENT_START'}))
  local function run(v)
    local ty = type(v)
    if v == require('lyaml').null then
      assert(emit({type = 'SCALAR', value = 'null'}))
    elseif ty == 'number' or ty == 'boolean' then
      assert(emit({type = 'SCALAR', value = tostring(v)}))
    elseif ty == 'string' then
      assert(emit({type = 'SCALAR', value = v, style = v == '' and 'SINGLE_QUOTED' or nil}))
    elseif ty == 'table' then
      if not next(v) then
        assert(emit({type = 'MAPPING_START'}))
        assert(emit({type = 'MAPPING_END'}))
      elseif isarray(v) then
        assert(emit({type = 'SEQUENCE_START'}))
        for _, value in ipairs(v) do
          run(value)
        end
        assert(emit({type = 'SEQUENCE_END'}))
      else
        assert(emit({type = 'MAPPING_START'}))
        local sortedKeys = {}
        for name in pairs(v) do
          table.insert(sortedKeys, name)
        end
        table.sort(sortedKeys, keycomp)
        local names = {}
        for _, name in ipairs(v == api and fieldOrder or {}) do
          table.insert(names, name)
        end
        for _, name in ipairs(sortedKeys) do
          table.insert(names, name)
        end
        local handled = {}
        for _, name in ipairs(names) do
          local value = v[name]
          if value ~= nil and not handled[name] then
            handled[name] = true
            run(name)
            run(value)
          end
        end
        assert(emit({type = 'MAPPING_END'}))
      end
    else
      error('invalid type ' .. ty)
    end
  end
  run(api)
  assert(emit({type = 'DOCUMENT_END', implicit = true}))
  return select(2, assert(emit({type = 'STREAM_END'})))
end

return {
  parse = parse,
  parseFile = function(f)
    local file = io.open(f, 'r')
    local str = file:read('*all')
    file:close()
    return parse(str)
  end,
  pprint = api2yaml,
}
