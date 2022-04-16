return (function(id)
  -- TODO real implementation of GetChatWindowInfo
  if id == 1 then
    return 'General', 10, 1, 1, 1, 1, 1, 1, 1
  else
    return 'Chat' .. id, 10, 1, 1, 1, 1, nil, nil, nil
  end
end)(...)
