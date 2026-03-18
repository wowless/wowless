local T, CreateCallback = ...
return {
  factory = function()
    return T.checkFuntainerFactory(CreateCallback)
  end,
  funtainerarg = function()
    local msg = 'Usage: C_FunctionContainers.CreateCallback(func)'
    return T.match(2, false, msg, pcall(CreateCallback, CreateCallback(function() end)))
  end,
}
