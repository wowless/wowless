describe('statemachine', function()
  local tests = {
    empty = {
      init = '',
      success = true,
      states = {},
      transitions = {},
    },
    failure = {
      init = 'false',
      success = false,
      state = {
        foo = false,
      },
      states = {
        ['false'] = function(s)
          assert.False(s.foo)
        end,
        ['true'] = function(s)
          assert.True(s.foo)
        end,
      },
      transitions = {
        tofalse = {
          to = 'false',
          func = function(s)
            s.foo = false
          end,
        },
        totrue = {
          to = 'true',
          func = function(s)
            s.foo = false -- here is the error
          end,
        },
      },
    },
    success = {
      init = 'false',
      success = true,
      state = {
        foo = false,
      },
      states = {
        ['false'] = function(s)
          assert.False(s.foo)
        end,
        ['true'] = function(s)
          assert.True(s.foo)
        end,
      },
      transitions = {
        tofalse = {
          to = 'false',
          func = function(s)
            s.foo = false
          end,
        },
        totrue = {
          to = 'true',
          func = function(s)
            s.foo = true
          end,
        },
      },
    },
  }
  local checkStateMachine
  do
    local env = {}
    loadfile('addon/Wowless/statemachine.lua')('foo', env)
    checkStateMachine = env.checkStateMachine
  end
  for k, v in pairs(tests) do
    it(k, function()
      local success, msg = pcall(checkStateMachine, v.states, v.transitions, v.init, v.state)
      assert.same(v.success, success, msg)
    end)
  end
end)
