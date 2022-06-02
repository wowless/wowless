describe('framework', function()
  local test = (function()
    local env = {}
    loadfile('framework.lua')('foo', env)
    return env.test
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
          }
        end,
      }
    end
    local expected = {
      a = {
        b = {
          c = 'spec/framework_spec.lua:15: doh',
          d = 'spec/framework_spec.lua:18: wow',
        },
      },
    }
    assert.same(expected, test(input))
  end)
end)
