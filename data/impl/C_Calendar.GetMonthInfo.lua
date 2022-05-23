local calendar, offset = ...
local date = require('date')
local month = date(calendar.currentYear, calendar.currentMonth, 1)
assert(month:addmonths(offset or 0))
return {
  firstWeekday = month:getweekday(),
  month = month:getmonth(),
  numDays = date.diff(date(month):addmonths(1), month):spandays(),
  year = month:getyear(),
}
