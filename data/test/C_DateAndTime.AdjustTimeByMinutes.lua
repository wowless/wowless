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
  [-40] = {
    day = day,
    hour = 12,
    minute = 44,
    month = 5,
    monthDay = 23,
    weekday = 2,
    year = 2022,
  },
  [0] = T.mixin({}, input),
  [40] = {
    day = day,
    hour = 14,
    minute = 4,
    month = 5,
    monthDay = 23,
    weekday = 2,
    year = 2022,
  },
}
local t = {}
for offset, expected in pairs(tests) do
  t[tostring(offset)] = function()
    local actual = T.retn(1, T.env.C_DateAndTime.AdjustTimeByMinutes(input, offset))
    assert(actual ~= input)
    return T.assertRecursivelyEqual(expected, actual)
  end
end
return t
