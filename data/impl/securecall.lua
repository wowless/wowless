local env, func = ...
assert(func, 'securecall of nil function')
if type(func) == 'string' then
  assert(env[func], 'securecall of unknown function ' .. func)
  func = env[func]
end
return securecall(func, select(3, ...))
