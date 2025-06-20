return function(script)
  pcall(loadstring(script))
  -- TODO fire UI_ERROR_MESSAGE on failure
end
