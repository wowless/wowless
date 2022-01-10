local env, arg = ...
if arg == nil or arg == 0 then
  return env
else
  return getfenv(arg)
end
