local T, getfenv, loadstring, setfenv = ...
return {
  globalenv = function()
    setfenv(1, {})
    T.assertEquals(T.env, getfenv(loadstring('')))
  end,
}
