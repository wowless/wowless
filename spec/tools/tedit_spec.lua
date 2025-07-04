describe('tedit', function()
  local tedit = require('tools.tedit')
  local tcopy = require('pl.tablex').deepcopy
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
    ['root change'] = {
      edit = {
        _change = {
          from = 42,
          to = 'foo',
        },
      },
      input = 42,
      output = 'foo',
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
    ['simple remove'] = {
      edit = {
        _remove = {
          foo = 42,
        },
      },
      input = {
        foo = 42,
        bar = 'baz',
      },
      output = {
        bar = 'baz',
      },
    },
    ['multichange'] = {
      edit = {
        k1 = {
          _add = {
            k2 = 42,
          },
        },
        _add = {
          k3 = 99,
        },
      },
      input = {
        k1 = {},
      },
      output = {
        k1 = {
          k2 = 42,
        },
        k3 = 99,
      },
    },
  }
  for k, v in pairs(tests) do
    it(k, function()
      local input = tcopy(v.input)
      local edit = tcopy(v.edit)
      local output = tedit(input, edit)
      assert.same(v.output, output)
      assert.same(v.input, input)
      assert.same(v.edit, edit)
    end)
  end
end)
