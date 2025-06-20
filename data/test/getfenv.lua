local T = ...
return {
  fnarg = function()
    return {
      set = function()
        local function f() end
        local t = {}
        T.check1(f, T.env.setfenv(f, t))
        T.check1(t, T.env.getfenv(f))
      end,
      unset = function()
        local function f() end
        T.check1(T.env, T.env.getfenv(f))
      end,
    }
  end,
  numarg = function()
    return {
      oneset = function()
        local function f()
          return T.env.getfenv(1)
        end
        local t = {}
        T.check1(f, T.env.setfenv(f, t))
        T.check1(t, f())
      end,
      oneunset = function()
        local function f()
          return T.env.getfenv(1)
        end
        T.check1(T.env, f())
      end,
      zero = function()
        T.check1(T.env, T.env.getfenv(0))
      end,
    }
  end,
}
