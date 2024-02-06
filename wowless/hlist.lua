local function nextentry(h, v)
  local k = v == nil and 0 or h.set[v]
  return k and h.list[k + 1]
end

local hlistMT = {
  __index = {
    entries = function(h)
      return nextentry, h
    end,
    has = function(h, v)
      return not not h.set[v]
    end,
    insert = function(h, v)
      if not h.set[v] then
        local n = #h.list + 1
        h.list[n] = v
        h.set[v] = n
      end
    end,
    remove = function(h, v)
      local k = h.set[v]
      if k then
        local n = #h.list
        if k ~= n then
          local vv = h.list[n]
          h.list[k] = vv
          h.set[vv] = k
        end
        h.list[n] = nil
        h.set[v] = nil
      end
    end,
  },
  __metatable = 'hlist',
}

return function()
  return setmetatable({ list = {}, set = {} }, hlistMT)
end
