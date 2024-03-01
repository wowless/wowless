local t = ...
local t1 = {
  day = 0,
  hour = 14,
  minute = 25,
  month = 6,
  monthDay = 24,
  weekday = 5,
  year = 2021,
}
local t2 = {
  day = 0,
  hour = 13,
  minute = 24,
  month = 5,
  monthDay = 23,
  weekday = 2,
  year = 2022,
}
local function f(a, b)
  return t.retn(1, t.env.C_DateAndTime.CompareCalendarTime(a, b))
end
return {
  equal1 = function()
    t.assertEquals(0, f(t1, t1))
  end,
  equal2 = function()
    t.assertEquals(0, f(t2, t2))
  end,
  greaterThan = function()
    t.assertEquals(-1, f(t2, t1))
  end,
  lessThan = function()
    t.assertEquals(1, f(t1, t2))
  end,
}
