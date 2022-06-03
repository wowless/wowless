describe('framework', function()
  local test = (function()
    local env = {}
    loadfile('addon/Wowless/framework.lua')('foo', env)
    return env.test
  end)()
  it('works', function()
    local order = {}
    local function input()
      table.insert(order, 'top')
      return {
        a = function()
          table.insert(order, 'a')
          return {
            b = function()
              table.insert(order, 'b')
              return {
                c = function()
                  table.insert(order, 'c')
                  error('doh')
                end,
                d = function()
                  table.insert(order, 'd')
                  error('wow')
                end,
              }
            end,
            e = function()
              table.insert(order, 'e')
              return {
                f = function()
                  table.insert(order, 'f')
                end,
                g = function()
                  table.insert(order, 'g')
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
          c = 'spec/addon/framework_spec.lua:20: doh',
          d = 'spec/addon/framework_spec.lua:24: wow',
        },
      },
    }
    assert.same(expected, test(input))
    assert.same('top,a,b,c,d,e,f,g', table.concat(order, ','))
  end)
end)
