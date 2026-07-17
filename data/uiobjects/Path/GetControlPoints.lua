return function(self)
  -- Ordering not modeled yet: a real client doesn't return these in plain
  -- insertion order (needs a deep dive to distinguish "sorted by order"
  -- from "reverse order of creation", among other possibilities).
  local ret = {}
  for kid in self.controlPoints:entries() do
    table.insert(ret, kid)
  end
  return unpack(ret)
end
