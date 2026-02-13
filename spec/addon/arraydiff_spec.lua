describe('arraydiff', function()
  local arraydiff
  do
    local env = {}
    loadfile('addon/Wowless/arraydiff.lua')('foo', env)
    arraydiff = env.arraydiff
  end

  local tests = {
    ['both empty'] = {
      a = {},
      b = {},
      diff = {},
    },
    ['identical'] = {
      a = { 'a', 'b', 'c' },
      b = { 'a', 'b', 'c' },
      diff = {},
    },
    ['all deleted'] = {
      a = { 'a', 'b' },
      b = {},
      diff = {
        { op = 'delete', idx = 1, value = 'a' },
        { op = 'delete', idx = 2, value = 'b' },
      },
    },
    ['all inserted'] = {
      a = {},
      b = { 'a', 'b' },
      diff = {
        { op = 'insert', idx = 1, value = 'a' },
        { op = 'insert', idx = 2, value = 'b' },
      },
    },
    ['change'] = {
      a = { 'a', 'hello', 'c' },
      b = { 'a', 'hallo', 'c' },
      diff = {
        { op = 'change', idx = 2, expected = 'hello', actual = 'hallo' },
      },
    },
    ['dissimilar substitution'] = {
      a = { 'a', 'b', 'c' },
      b = { 'a', 'x', 'c' },
      diff = {
        { op = 'delete', idx = 2, value = 'b' },
        { op = 'insert', idx = 2, value = 'x' },
      },
    },
    ['deletion in middle'] = {
      a = { 'a', 'b', 'c' },
      b = { 'a', 'c' },
      diff = {
        { op = 'delete', idx = 2, value = 'b' },
      },
    },
    ['insertion in middle'] = {
      a = { 'a', 'b' },
      b = { 'a', 'x', 'b' },
      diff = {
        { op = 'insert', idx = 2, value = 'x' },
      },
    },
    ['prefix addition'] = {
      a = { 'a', 'b' },
      b = { 'x', 'a', 'b' },
      diff = {
        { op = 'insert', idx = 1, value = 'x' },
      },
    },
    ['suffix addition'] = {
      a = { 'a', 'b' },
      b = { 'a', 'b', 'x' },
      diff = {
        { op = 'insert', idx = 3, value = 'x' },
      },
    },
    ['prefix removal'] = {
      a = { 'a', 'b', 'c' },
      b = { 'b', 'c' },
      diff = {
        { op = 'delete', idx = 1, value = 'a' },
      },
    },
    ['suffix removal'] = {
      a = { 'a', 'b', 'c' },
      b = { 'a', 'b' },
      diff = {
        { op = 'delete', idx = 3, value = 'c' },
      },
    },
    ['single equal'] = {
      a = { 'a' },
      b = { 'a' },
      diff = {},
    },
    ['single similar'] = {
      a = { 'ab' },
      b = { 'ac' },
      diff = {
        { op = 'change', idx = 1, expected = 'ab', actual = 'ac' },
      },
    },
    ['single dissimilar'] = {
      a = { 'a' },
      b = { 'x' },
      diff = {
        { op = 'delete', idx = 1, value = 'a' },
        { op = 'insert', idx = 1, value = 'x' },
      },
    },
    ['multiple changes'] = {
      a = { 'a', 'hello', 'b', 'world' },
      b = { 'a', 'hallo', 'b', 'wurld' },
      diff = {
        { op = 'change', idx = 2, expected = 'hello', actual = 'hallo' },
        { op = 'change', idx = 4, expected = 'world', actual = 'wurld' },
      },
    },
  }

  for name, test in pairs(tests) do
    it(name, function()
      assert.same(test.diff, arraydiff(test.a, test.b))
    end)
  end
end)
