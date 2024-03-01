local t = ...
local day = t.data.build.flavor ~= 'Mainline' and 0 or nil
local input = {
  day = day,
  hour = 13,
  minute = 24,
  month = 5,
  monthDay = 23,
  weekday = 2,
  year = 2022,
}
local tests = {
  [-365] = {
    day = day,
    hour = 13,
    minute = 24,
    month = 5,
    monthDay = 23,
    weekday = 1,
    year = 2021,
  },
  [-3] = {
    day = day,
    hour = 13,
    minute = 24,
    month = 5,
    monthDay = 20,
    weekday = 6,
    year = 2022,
  },
  [0] = t.mixin({}, input),
  [14] = {
    day = day,
    hour = 13,
    minute = 24,
    month = 6,
    monthDay = 6,
    weekday = 2,
    year = 2022,
  },
  [365] = {
    day = day,
    hour = 13,
    minute = 24,
    month = 5,
    monthDay = 23,
    weekday = 3,
    year = 2023,
  },
}
local tt = {}
for offset, expected in pairs(tests) do
  tt[tostring(offset)] = function()
    local actual = t.retn(1, t.env.C_DateAndTime.AdjustTimeByDays(input, offset))
    assert(actual ~= input)
    return t.assertRecursivelyEqual(expected, actual)
  end
end
return tt
