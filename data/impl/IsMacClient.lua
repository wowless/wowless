local api = ...
return function()
  return api.platform == 'mac'
end
