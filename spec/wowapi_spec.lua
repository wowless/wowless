describe('wowapi #small', function()
  for f in require('lfs').dir('wowapi') do
    if f:sub(-4) == '.lua' then
      describe(f:sub(1, -5), function()
        local t = dofile('wowapi/' .. f)
        local impl = t.impl
        for _, test in ipairs(t.tests) do
          (test.pending and pending or it)(test.name, function()
            assert.same(test.outputs, impl(test.inputs))
          end)
        end
      end)
    end
  end
end)