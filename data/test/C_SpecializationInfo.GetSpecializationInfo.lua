local T, GetSpecializationInfo = ...
return {
  nonsense = function()
    return T.match(10, 0, nil, nil, nil, nil, nil, 0, nil, 0, true, GetSpecializationInfo(999999))
  end,
}
