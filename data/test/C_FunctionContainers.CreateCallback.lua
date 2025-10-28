local T = ...
local f = T.env.C_FunctionContainers.CreateCallback
return {
  factory = function()
    return T.checkFuntainerFactory(f)
  end,
  funtainerarg = function()
    local msg = 'Usage: C_FunctionContainers.CreateCallback(func)'
    return T.match(2, false, msg, pcall(f, f(function() end)))
  end,
}
