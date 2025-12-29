local nop = function() end
return function()
  return {
    AddPoint = nop,
    SetType = nop,
  }
end
