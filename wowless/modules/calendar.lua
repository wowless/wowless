local date = require('date')
return function()
  local currentYear = 2004
  local currentMonth = 11
  return {
    ['C_Calendar.GetMonthInfo'] = function(offset)
      local month = date(currentYear, currentMonth, 1)
      assert(month:addmonths(offset or 0))
      return {
        firstWeekday = month:getweekday(),
        month = month:getmonth(),
        numDays = date.diff(date(month):addmonths(1), month):spandays(),
        year = month:getyear(),
      }
    end,
    ['C_Calendar.SetAbsMonth'] = function(month, year)
      currentMonth = month
      currentYear = year
    end,
    ['C_Calendar.SetMonth'] = function(offset)
      local d = date(currentYear, currentMonth, 1)
      assert(d:addmonths(offset))
      currentYear = d:getyear()
      currentMonth = d:getmonth()
    end,
  }
end
