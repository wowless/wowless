local calendarTime, days = ...
local util = require('wowless.util')
local date = util.calendarTimeToDate(calendarTime)
assert(date:adddays(days))
return util.dateToCalendarTime(date)
