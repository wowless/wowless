local api, time, delay, fn = ...
local stamp = time.stamp + delay
api.log(2, 'scheduling timer %.2f %s', stamp, tostring(fn))
time.timers:push(stamp, fn)
