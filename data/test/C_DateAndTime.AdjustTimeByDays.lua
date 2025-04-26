local T = ...
local day = T.data.build.gametype ~= 'Standard' and 0 or nil
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
  [0] = T.mixin({}, input),
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
local t = {}
for offset, expected in pairs(tests) do
  t[tostring(offset)] = function()
    local actual = T.retn(1, T.env.C_DateAndTime.AdjustTimeByDays(input, offset))
    assert(actual ~= input)
    return T.assertRecursivelyEqual(expected, actual)
  end
end
return t
