local mkdate = require('date')
return function(datalua)
  local day = datalua.build.gametype ~= 'Standard' and 0 or nil
  local function calendarTimeToDate(ct)
    return mkdate(ct.year, ct.month, ct.monthDay, ct.hour, ct.minute)
  end
  local function dateToCalendarTime(d)
    return {
      day = day,
      hour = d:gethours(),
      minute = d:getminutes(),
      month = d:getmonth(),
      monthDay = d:getday(),
      weekday = d:getweekday(),
      year = d:getyear(),
    }
  end
  return {
    ['C_DateAndTime.AdjustTimeByDays'] = function(calendarTime, days)
      local date = calendarTimeToDate(calendarTime)
      assert(date:adddays(days))
      return dateToCalendarTime(date)
    end,
    ['C_DateAndTime.AdjustTimeByMinutes'] = function(calendarTime, minutes)
      local date = calendarTimeToDate(calendarTime)
      assert(date:addminutes(minutes))
      return dateToCalendarTime(date)
    end,
    ['C_DateAndTime.CompareCalendarTime'] = function(a, b)
      local da, db = calendarTimeToDate(a), calendarTimeToDate(b)
      if da < db then
        return 1
      elseif da > db then
        return -1
      else
        return 0
      end
    end,
  }
end
