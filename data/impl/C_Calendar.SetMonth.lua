local calendar, offset = ...
local d = require('date')(calendar.currentYear, calendar.currentMonth, 1)
assert(d:addmonths(offset))
calendar.currentYear = d:getyear()
calendar.currentMonth = d:getmonth()
