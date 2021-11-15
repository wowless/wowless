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
  local tx = sub(x, 1, 1)
  assert(tx == 't' or tx == 'f' or tx == 'u')
  return pairs(data[tonumber(sub(x, 2))])
end

local function resolve(data, top, depth)
  if top == nil then
    return nil
  end
  local refs = {}
  local function fun(x, lvl)
    if lvl >= depth then
      return x
    end
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
    elseif tx == 'm' then
      return '<metatable>'
    elseif tx == 'f' or tx == 'u' then
      refs[x] = true
      return fun('t' .. sub(x, 2), lvl + 1)
    elseif tx == 't' then
      refs[x] = true
      local t = {}
      for k, v in tpairs(data, x) do
        t[fun(k, lvl + 1)] = fun(v, lvl + 1)
      end
      return t
    else
      error('invalid type on ' .. x)
    end
  end
  return fun(top, 0)
end

local function names(data, rend)
  local result = {}
  local refs = {}
  local stack = { { '_G', rend } }
  while #stack > 0 do
    local str, r = unpack(table.remove(stack))
    refs[r] = true
    for k, v in data:tpairs(r) do
      local tk = sub(k, 1, 1)
      local s = str
      if tk == 'm' then
        s = 'getmetatable(' .. s .. ')'
      elseif tk == 'e' then
        s = 'getfenv(' .. s .. ')'
      elseif tk == 'n' or tk == 'b' then
        s = s .. '[' .. sub(k, 2) .. ']'
      elseif tk == 's' then
        s = s .. '.' .. sub(k, 2)
      elseif tk == 't' or tk == 'f' or tk == 'u' then
        print('ignoring table key ' .. k)
      else
        error('invalid key ' .. k)
      end
      if v == rend then
        table.insert(result, s)
      elseif not refs[v] then
        local tv = sub(v, 1, 1)
        if tv == 't' or tv == 'u' or tv =='f' then
          table.insert(stack, { s, v })
        end
      end
    end
  end
  return result
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
    names = names,
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
  return setmetatable(env.TheFlatDumperData or env.WowlessSaverData, dataMT), env.TheFlatDumperBuildInfo
end
