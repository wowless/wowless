describe('C_DateAndTime.AdjustTimeByDays', function()
  local f = loadfile('data/impl/C_DateAndTime.AdjustTimeByDays.lua')
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
      monthDay = 20,
      hour = 13,
      minute = 24,
      weekday = 6,
    }
    assert.same(expected, f(t, -3))
  end)
  it('works with big negative arg', function()
    local expected = {
      year = 2021,
      month = 5,
      monthDay = 23,
      hour = 13,
      minute = 24,
      weekday = 1,
    }
    assert.same(expected, f(t, -365))
  end)
  it('works with positive arg', function()
    local expected = {
      year = 2022,
      month = 6,
      monthDay = 6,
      hour = 13,
      minute = 24,
      weekday = 2,
    }
    assert.same(expected, f(t, 14))
  end)
  it('works with big positive arg', function()
    local expected = {
      year = 2023,
      month = 5,
      monthDay = 23,
      hour = 13,
      minute = 24,
      weekday = 3,
    }
    assert.same(expected, f(t, 365))
  end)
end)
