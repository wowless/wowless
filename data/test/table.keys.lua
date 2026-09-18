local T, keys = ...
local cases = {
  array = { expected = { 1, 2, 3 }, t = { 10, 20, 30 } },
  empty = { expected = {}, t = {} },
  mixed = { expected = { 1, 2, 'foo', 'baz' }, t = { 1, 2, foo = 'bar', baz = 1 } },
}
local tests = {}
for name, case in pairs(cases) do
  tests[name] = function()
    local actual = keys(case.t)
    T.assertEquals(#case.expected, #actual)
    local seen = {}
    for _, v in ipairs(actual) do
      T.assertEquals(nil, seen[v])
      seen[v] = true
    end
    for _, v in ipairs(case.expected) do
      T.assertEquals(true, seen[v])
    end
  end
end
return tests
