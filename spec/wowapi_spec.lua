describe('wowapi #small', function()
  for f in require('lfs').dir('wowapi') do
    if f:sub(-4) == '.lua' then
      local fn = f:sub(1, -5)
      describe(fn, function()
        local t = dofile('wowapi/' .. f)
        it('has the right name', function()
          assert.same(fn, t.name)
        end)
        local impl = t.impl
        for _, test in ipairs(t.tests or {}) do
          (test.pending and pending or it)(test.name, function()
            assert.same(test.outputs, {impl(unpack(test.inputs))})
          end)
        end
      end)
    end
  end
end)