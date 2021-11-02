describe('classcolor', function()
  local modulefn = loadfile('data/modules/classcolor.lua')
  describe('GetClassColor', function()
    it('works', function()
      local env = {
        ColorMixin = { rofl = 42 },
        Mixin = function(t, u)
          for k, v in pairs(u) do
            t[k] = v
          end
          return t
        end,
      }
      local expected = {
        r = 0,
        g = 0,
        b = 0,
        rofl = 42,
      }
      assert.same(expected, modulefn(env).api.GetClassColor())
    end)
  end)
end)
