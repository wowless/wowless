local T = ...
return {
  globalenv = function()
    T.env.setfenv(1, {})
    T.assertEquals(T.env, T.env.getfenv(T.env.loadstring('')))
  end,
}
