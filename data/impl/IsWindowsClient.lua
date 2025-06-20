local api = ...
return function()
  return api.platform == 'windows'
end
