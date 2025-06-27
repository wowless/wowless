describe('tedit', function()
  local tedit = require('tools.tedit')
  local tests = {
    ['empty'] = {
      edit = {},
      input = {},
      output = {},
    },
    ['simple add'] = {
      edit = {
        _add = {
          a = 42,
          b = 'asdf',
        },
      },
      input = {},
      output = {
        a = 42,
        b = 'asdf',
      },
    },
    ['multiple scoped add'] = {
      edit = {
        foo = {
          bar = {
            _add = {
              baz = 42,
            },
          },
        },
        quux = {
          _add = {
            frob = 99,
          },
        },
      },
      input = {
        foo = {
          bar = {
            notbaz = 'zz',
          },
        },
        quux = {
          notfrob = 'yy',
        },
      },
      output = {
        foo = {
          bar = {
            baz = 42,
            notbaz = 'zz',
          },
        },
        quux = {
          frob = 99,
          notfrob = 'yy',
        },
      },
    },
    ['simple change'] = {
      edit = {
        foo = {
          _change = {
            from = 42,
            to = {
              rofl = 'copter',
            },
          },
        },
      },
      input = {
        foo = 42,
      },
      output = {
        foo = {
          rofl = 'copter',
        },
      },
    },
  }
  for k, v in pairs(tests) do
    it(k, function()
      assert.same(v.output, tedit(v.input, v.edit) or v.input)
    end)
  end
end)
