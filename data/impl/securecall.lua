local env, func = ...
assert(func, 'securecall of nil function')
if type(func) == 'string' then
  assert(env[func], 'securecall of unknown function ' .. func)
  func = env[func]
end
-- use tainted-lua if available
if securecall then
  return securecall(func, select(3, ...))
else
  return func(select(3, ...))
end
