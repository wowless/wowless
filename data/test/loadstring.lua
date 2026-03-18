local T, loadstring = ...
return {
  globalenv = function()
    T.env.setfenv(1, {})
    T.assertEquals(T.env, T.env.getfenv(loadstring('')))
  end,
}
