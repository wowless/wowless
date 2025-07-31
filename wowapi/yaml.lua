local mkemitter = require('yaml').emitter
local parse = require('lyaml').load

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
  local ta, tb = type(a), type(b)
  if ta ~= tb then
    return ta < tb
  end
  if ta == 'number' then
    return a < b
  elseif ta == 'string' then
    local la, lb = a:lower(), b:lower()
    return la < lb or la == lb and a < b
  else
    error('invalid table key type ' .. ta)
  end
end

local function api2yaml(api)
  local emitter = mkemitter()
  local emit = emitter.emit
  assert(emit({ type = 'STREAM_START' }))
  assert(emit({ type = 'DOCUMENT_START' }))
  local function run(v)
    local ty = type(v)
    if v == require('lyaml').null then
      assert(emit({ type = 'SCALAR', value = '' }))
    elseif ty == 'number' or ty == 'boolean' then
      assert(emit({ type = 'SCALAR', value = tostring(v) }))
    elseif ty == 'string' then
      local sq = v == '' or v == 'true' or v == 'false' or v == 'on' or tonumber(v)
      assert(emit({ type = 'SCALAR', value = v, style = sq and 'SINGLE_QUOTED' or nil }))
    elseif ty == 'table' then
      if not next(v) then
        assert(emit({ type = 'MAPPING_START' }))
        assert(emit({ type = 'MAPPING_END' }))
      elseif isarray(v) then
        assert(emit({ type = 'SEQUENCE_START' }))
        for _, value in ipairs(v) do
          run(value)
        end
        assert(emit({ type = 'SEQUENCE_END' }))
      else
        assert(emit({ type = 'MAPPING_START' }))
        local names = {}
        for name in pairs(v) do
          table.insert(names, name)
        end
        table.sort(names, keycomp)
        local handled = {}
        for _, name in ipairs(names) do
          local value = v[name]
          if value ~= nil and not handled[name] then
            handled[name] = true
            run(name)
            run(value)
          end
        end
        assert(emit({ type = 'MAPPING_END' }))
      end
    else
      error('invalid type ' .. ty)
    end
  end
  run(api)
  assert(emit({ type = 'DOCUMENT_END', implicit = true }))
  return select(2, assert(emit({ type = 'STREAM_END' })))
end

return {
  parse = parse,
  parseFile = function(f)
    local file = assert(io.open(f, 'r'), 'failed to open ' .. tostring(f))
    local str = file:read('*all')
    file:close()
    return assert(parse(str), 'could not parse ' .. tostring(f) .. ' as yaml')
  end,
  pprint = api2yaml,
}
