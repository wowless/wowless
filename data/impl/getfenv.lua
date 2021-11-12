local env, arg = ...
if arg == 0 then
  return env
else
  return getfenv(arg)
end
