local function nop() end
return function(datalua)
  local mts = {}
  for k, v in pairs(datalua.luaobjects) do
    local index = {}
    for vk in pairs(v) do
      index[vk] = nop
    end
    mts[k] = {
      __index = index,
      __metatable = false,
    }
  end

  local objs = {}
  for k in pairs(datalua.luaobjects) do
    objs[k] = setmetatable({}, { __mode = 'k' })
  end

  local function Create(k)
    local mt = assert(mts[k], k)
    local v = setmetatable({}, mt)
    objs[k][v] = true
    return v
  end

  local function IsType(k, v)
    return assert(objs[k], k)[v] ~= nil
  end

  return {
    Create = Create,
    IsType = IsType,
  }
end
