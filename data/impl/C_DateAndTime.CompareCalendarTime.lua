local a, b = ...
local toDate = require('wowless.util').calendarTimeToDate
local da, db = toDate(a), toDate(b)
if da < db then
  return -1
elseif da > db then
  return 1
else
  return 0
end
