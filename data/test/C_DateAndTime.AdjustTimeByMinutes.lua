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
  [-40] = {
    day = day,
    hour = 12,
    minute = 44,
    month = 5,
    monthDay = 23,
    weekday = 2,
    year = 2022,
  },
  [0] = t.mixin({}, input),
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
local tt = {}
for offset, expected in pairs(tests) do
  tt[tostring(offset)] = function()
    local actual = t.retn(1, t.env.C_DateAndTime.AdjustTimeByMinutes(input, offset))
    assert(actual ~= input)
    return t.assertRecursivelyEqual(expected, actual)
  end
end
return tt
