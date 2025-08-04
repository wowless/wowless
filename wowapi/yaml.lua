local mkemitter = require('yaml').emitter
local lyamlnull = require('lyaml').null
local parse = require('wowapi.cyaml').parse
local sorted = require('pl.tablex').sort

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
  a, b = tostring(a), tostring(b)
  local aa, bb = a:lower(), b:lower()
  return aa < bb or aa == bb and a < b
end

local function api2yaml(api)
  local emitter = mkemitter()
  local emit = emitter.emit
  assert(emit({ type = 'STREAM_START' }))
  assert(emit({ type = 'DOCUMENT_START' }))
  local function run(v)
    assert(v ~= lyamlnull)
    local ty = type(v)
    if ty == 'number' or ty == 'boolean' then
      assert(emit({ type = 'SCALAR', value = tostring(v) }))
    elseif ty == 'string' then
      local sq = v == '' or v == 'true' or v == 'false' or v == 'on' or tonumber(v)
      assert(emit({ type = 'SCALAR', value = v, style = sq and 'SINGLE_QUOTED' or nil }))
    elseif ty == 'table' then
      if not next(v) then
        assert(emit({ type = 'SCALAR', value = '' }))
      elseif isarray(v) then
        assert(emit({ type = 'SEQUENCE_START' }))
        for _, value in ipairs(v) do
          run(value)
        end
        assert(emit({ type = 'SEQUENCE_END' }))
      else
        assert(emit({ type = 'MAPPING_START' }))
        for vk, vv in sorted(v, keycomp) do
          run(vk)
          run(vv)
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
