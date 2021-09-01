local function loadData(filename)
  local env = {}
  setfenv(loadfile(filename), env)()
  return env.WowlessSaverData
end

local sub = string.sub

local function ref(data, start, ...)
  local x = start
  for i = 1, select('#', ...) do
    local ty = sub(x, 1, 1)
    assert(ty == 't' or ty == 'f' or ty == 'u')
    x = data[tonumber(sub(x, 2))][select(i, ...)]
  end
  return x
end

local function tpairs(data, x)
  assert(type(x) == 'string')
  assert(sub(x, 1, 1) == 't')
  return pairs(data[tonumber(sub(x, 2))])
end

local function resolve(data, top)
  if top == nil then
    return nil
  end
  local refs = {}
  local function fun(x)
    assert(type(x) == 'string', tostring(x) .. ' is not a string')
    assert(not refs[x], 'unsupported loop in structure')
    local tx = sub(x, 1, 1)
    if tx == 'n' then
      return tonumber(sub(x, 2))
    elseif tx == 's' then
      return sub(x, 2)
    elseif tx == 'b' then
      return x == 'btrue'
    elseif tx == 'e' then
      return '<function environment>'
    elseif tx == 'f' or tx == 'u' then
      refs[x] = true
      return fun('t' .. sub(x, 2))
    elseif tx == 't' then
      refs[x] = true
      local t = {}
      for k, v in tpairs(data, x) do
        t[fun(k)] = fun(v)
      end
      return t
    else
      error('invalid type on ' .. x)
    end
  end
  return fun(top)
end

local function global(data, ...)
  return ref(data, 't1', ...)
end

local function capsule(data, ...)
  return global(data, 'sSimpleCheckout', 'sOnLoad', 'e', ...)
end

local function recursiveMixin(t, u)
  for k, v in pairs(u) do
    local tv = t[k]
    if tv == nil or type(tv) ~= 'table' or type(v) ~= 'table' then
      t[k] = v
    else
      recursiveMixin(tv, v)
    end
  end
  return t
end

local function luaEnums(data, r)
  local result = {}
  for k, v in tpairs(data, r) do
    if sub(k, 1, 4) == 'sLE_' or sub(k, 1, 8) == 'sNUM_LE_' then
      result[sub(k, 2)] = resolve(data, v)
    end
  end
  return result
end

local function otherConstants(data)
  local keys = {
    'BINDING_HEADER_MOVEMENT',
    'ITEM_QUALITY0_DESC',
    'ITEM_QUALITY1_DESC',
    'ITEM_QUALITY2_DESC',
    'ITEM_QUALITY3_DESC',
    'ITEM_QUALITY4_DESC',
    'ITEM_QUALITY5_DESC',
    'ITEM_QUALITY6_DESC',
    'ITEM_QUALITY7_DESC',
    'ITEM_QUALITY8_DESC',
    'ITEM_QUALITY9_DESC',
    'UK_AADC_POPUP_TEXT',
  }
  local result = {}
  for _, k in ipairs(keys) do
    result[k] = resolve(data, global(data, 's' .. k))
  end
  return result
end

do
  local data = loadData(arg[1])
  local result = {}
  recursiveMixin(result, { Constants = resolve(data, global(data, 'sConstants')) })
  recursiveMixin(result, { Constants = resolve(data, capsule(data, 'sConstants')) })
  recursiveMixin(result, { Enum = resolve(data, global(data, 'sEnum')) })
  recursiveMixin(result, { Enum = resolve(data, capsule(data, 'sEnum')) })
  recursiveMixin(result, luaEnums(data, global(data)))
  recursiveMixin(result, luaEnums(data, capsule(data)))
  recursiveMixin(result, otherConstants(data))

  local keys = {}
  for k in pairs(result) do
    table.insert(keys, k)
  end
  table.sort(keys)
  local pretty = require('pl.pretty').write
  for _, k in ipairs(keys) do
    print(k .. ' = ' .. pretty(result[k]))
  end
end
