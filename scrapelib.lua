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

local dataMT = {
  __index = {
    capsule = capsule,
    global = global,
    ref = ref,
    resolve = resolve,
    tpairs = tpairs,
  },
  __metatable = 'WowlessSaverData',
  __newindex = function()
    error('cannot modify a scrape table')
  end,
}

return function(filename)
  local env = {}
  setfenv(loadfile(filename), env)()
  return setmetatable(env.WowlessSaverData, dataMT)
end
