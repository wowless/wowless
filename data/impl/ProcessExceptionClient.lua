local log = ...
return function(msg)
  log(1, '[ProcessExceptionClient] %s', msg)
end
