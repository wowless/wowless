return function(id)
  -- TODO real implementation of GetChatWindowInfo
  if id == 1 then
    return 'General', 10, 1, 1, 1, 1, true, true, 1, false
  else
    return 'Chat' .. id, 10, 1, 1, 1, 1, false, false, nil, false
  end
end
