local T, removevalue = ...
local cases = {
  absent = { count = 0, expected = { 10, 20, 30 }, t = { 10, 20, 30 }, value = 40 },
  array_present = { count = 1, expected = { 10, 30 }, t = { 10, 20, 30 }, value = 20 },
  duplicates = { count = 2, expected = { 1, 1, 1 }, t = { 1, 2, 1, 2, 1 }, value = 2 },
  empty = { count = 0, expected = {}, t = {}, value = 1 },
}
local tests = {}
for name, case in pairs(cases) do
  tests[name] = function()
    local t = case.t
    T.check1(case.count, removevalue(t, case.value))
    return T.assertScalarArrayEquals(case.expected, t)
  end
end
return tests
