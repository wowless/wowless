describe('util', function()
  local util = require('wowless.util')
  describe('tget', function()
    local tget = util.tget
    it('works', function()
      assert.Nil(tget({}, 'foo'))
      assert.same(42, tget({ foo = 42 }, 'foo'))
      assert.Nil(tget({}, 'foo.bar'))
      assert.Nil(tget({ foo = {} }, 'foo.bar'))
      assert.same(42, tget({ foo = { bar = 42 } }, 'foo.bar'))
    end)
  end)
  describe('tset', function()
    local tset = util.tset
    it('works', function()
      assert.same({ foo = 42 }, tset({}, 'foo', 42))
      assert.same({ foo = { bar = 42 } }, tset({}, 'foo.bar', 42))
    end)
  end)
  describe('readfile', function()
    local readfile = util.readfile
    local path = require('path')
    local readme = readfile('README.md')

    local readmeCases = {
      ['filenames with no path parts'] = 'README.md',
      ['relative paths with dot slash'] = './././././README.md',
      ['absolute paths'] = path.join(path.currentdir(), 'README.md'),
      ['filenames case insensitively'] = 'readme.md',
    }
    for name, p in pairs(readmeCases) do
      it('reads ' .. name, function()
        assert.same(readme, readfile(p))
      end)
    end

    it('reads relative paths', function()
      local absolute = readfile(path.join(path.currentdir(), 'spec/wowless/util_spec.lua'))
      assert.same(absolute, readfile('spec/wowless/util_spec.lua'))
    end)

    it('does not just stop at a good filename', function()
      assert.has.errors(function()
        readfile('README.md/foo')
      end)
    end)
  end)
end)
