local env = ...

local function returner(...)
  local t = {...}
  local n = select('#', ...)
  return function() return unpack(t, 1, n) end
end

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
        local retfn = returner(oldfn(...))
        fn(...)
        return retfn()
      end
    end,
  },
}
