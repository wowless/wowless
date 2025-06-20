return function(script)
  pcall(loadstring_untainted(script))
  -- TODO fire UI_ERROR_MESSAGE on failure
end
