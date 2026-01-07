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
  return function(k)
    local mt = assert(mts[k], k)
    return setmetatable({}, mt)
  end
end
