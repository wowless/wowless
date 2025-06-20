local api = ...
return function()
  return api.platform == 'linux'
end
