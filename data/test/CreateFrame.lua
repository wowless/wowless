local t = ...
return {
  NonsenseType = function()
    assert(not pcall(t.env.CreateFrame, 'NonsenseType'))
  end,
}
