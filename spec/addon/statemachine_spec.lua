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
    transitivity = {
      init = '0',
      success = false, -- issue #417
      state = {
        value = 0,
      },
      states = {
        ['0'] = function(s)
          assert.same(0, s.value)
        end,
        ['1'] = function(s)
          assert.same(1, s.value)
        end,
        ['2'] = function(s)
          assert.same(2, s.value)
        end,
      },
      transitions = {
        increment = {
          edges = {
            ['0'] = '1',
            ['1'] = '2',
          },
          func = function(s)
            s.value = s.value + 1
          end,
        },
        reset = {
          to = '0',
          func = function(s)
            s.value = 0
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
