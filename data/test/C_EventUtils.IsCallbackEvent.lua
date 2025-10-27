local T = ...
local f = T.env.C_EventUtils.IsCallbackEvent
local tests = {}
for k, v in pairs(T.data.events) do
  tests[k] = function()
    return T.match(1, v.callback, f(k))
  end
end
return tests
