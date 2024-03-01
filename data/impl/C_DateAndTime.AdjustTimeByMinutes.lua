local datalua, calendarTime, minutes = ...
local util = require('wowless.util')
local date = util.calendarTimeToDate(calendarTime)
assert(date:addminutes(minutes))
return util.dateToCalendarTime(datalua, date)
