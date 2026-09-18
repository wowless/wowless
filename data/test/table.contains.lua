local T, contains = ...
local cases = {
  absent = { expected = false, t = { 10, 20, 30 }, value = 40 },
  array_present = { expected = true, t = { 10, 20, 30 }, value = 20 },
  empty = { expected = false, t = {}, value = 1 },
  mixed_present = { expected = true, t = { 1, 2, baz = 1, foo = 'bar' }, value = 'bar' },
}
local tests = {}
for name, case in pairs(cases) do
  tests[name] = function()
    return T.match(1, case.expected, contains(case.t, case.value))
  end
end
return tests
