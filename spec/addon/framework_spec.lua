describe('framework', function()
  local tests = (function()
    local env = {}
    loadfile('addon/Wowless/framework.lua')('foo', env)
    return env.tests
  end)()
  it('works', function()
    local function input()
      return {
        a = function()
          return {
            b = function()
              return {
                c = function()
                  error('doh')
                end,
                d = function()
                  error('wow')
                end,
              }
            end,
            e = function()
              return {
                f = function() end,
                g = function() end,
              }
            end,
          }
        end,
      }
    end
    local expected = {
      { '' },
      { 'a' },
      { 'a.b' },
      { 'a.b.c', 'spec/addon/framework_spec.lua:15: doh' },
      { 'a.b.d', 'spec/addon/framework_spec.lua:18: wow' },
      { 'a.e' },
      { 'a.e.f' },
      { 'a.e.g' },
    }
    local actual = {}
    for t, r in tests(input) do
      table.insert(actual, { table.concat(t, '.'), r })
    end
    assert.same(expected, actual)
  end)
end)
