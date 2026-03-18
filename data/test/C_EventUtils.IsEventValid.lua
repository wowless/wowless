local T, IsEventValid = ...
local tests = {}
for k, v in pairs(T.data.events) do
  tests[k] = function()
    return T.match(1, v.registerable, IsEventValid(k))
  end
end
return tests
