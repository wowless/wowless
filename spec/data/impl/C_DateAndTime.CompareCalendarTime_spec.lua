describe('C_DateAndTime.CompareCalendarTime', function()
  local f = loadfile('data/impl/C_DateAndTime.CompareCalendarTime.lua')
  local t1 = {
    year = 2021,
    month = 6,
    monthDay = 24,
    hour = 14,
    minute = 25,
  }
  local t2 = {
    year = 2022,
    month = 5,
    monthDay = 23,
    hour = 13,
    minute = 24,
  }
  it('works', function()
    assert.same(0, f(t1, t1))
    assert.same(-1, f(t1, t2))
    assert.same(1, f(t2, t1))
    assert.same(0, f(t2, t2))
  end)
end)
