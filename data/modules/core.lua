local env = ...

return {
  api = {
    getfenv = function(arg)
      if arg == 0 then
        return env
      else
        return getfenv(arg)
      end
    end,
    hooksecurefunc = function(arg1, arg2, arg3)
      local tbl, name, fn
      if arg3 ~= nil then
        tbl, name, fn = arg1, arg2, arg3
      else
        tbl, name, fn = env, arg1, arg2
      end
      local oldfn = tbl[name]
      tbl[name] = function(...)
        local returns = {oldfn(...)}
        fn(...)
        return unpack(returns)
      end
    end,
  },
}
