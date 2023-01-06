local env, func = ...
assert(func, 'securecall of nil function')
if type(func) == 'string' then
  local f = env.get(func)
  assert(f, 'securecall of unknown function ' .. func)
  func = f
end
return securecall(func, select(3, ...))
