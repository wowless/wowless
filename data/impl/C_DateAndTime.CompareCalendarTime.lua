local function toDate(k)
  return require('date')(k.year, k.month, k.monthDay, k.hour, k.minute)
end
local a, b = ...
local da, db = toDate(a), toDate(b)
if da < db then
  return -1
elseif da > db then
  return 1
else
  return 0
end
