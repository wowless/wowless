local T, IsCallbackEvent = ...
local tests = {}
for k, v in pairs(T.data.events) do
  tests[k] = function()
    return T.match(1, v.callback, IsCallbackEvent(k))
  end
end
return tests
