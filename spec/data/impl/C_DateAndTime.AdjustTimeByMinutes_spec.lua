describe('C_DateAndTime.AdjustTimeByMinutes', function()
  local f = loadfile('data/impl/C_DateAndTime.AdjustTimeByMinutes.lua')
  local t = {
    year = 2022,
    month = 5,
    monthDay = 23,
    hour = 13,
    minute = 24,
    weekday = 2,
  }
  it('works with zero arg', function()
    assert.same(t, f(t, 0))
  end)
  it('works with negative arg', function()
    local expected = {
      year = 2022,
      month = 5,
      monthDay = 23,
      hour = 12,
      minute = 44,
      weekday = 2,
    }
    assert.same(expected, f(t, -40))
  end)
  it('works with positive arg', function()
    local expected = {
      year = 2022,
      month = 5,
      monthDay = 23,
      hour = 14,
      minute = 4,
      weekday = 2,
    }
    assert.same(expected, f(t, 40))
  end)
end)
