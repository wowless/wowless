local eventqueue = ...
return function()
  eventqueue.QueueEvent('TIME_PLAYED_MSG', 3600, 600)
end
