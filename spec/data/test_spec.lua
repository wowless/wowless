describe('test', function()
  local impls = require('build.data.impl')
  for _, f in ipairs(require('pl.dir').getfiles('data/test')) do
    local t = f:sub(11, -5)
    describe(t, function()
      it('references an impl', function()
        assert(impls[t])
      end)
      it('loads', function()
        assert(loadfile(f))
      end)
    end)
  end
end)
