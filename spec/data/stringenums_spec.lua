describe('stringenums', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local used = {}
      local function refty(ty)
        if ty.arrayof then
          refty(ty.arrayof)
        elseif ty.stringenum then
          used[ty.stringenum] = true
        end
      end
      local function reflist(xs)
        for _, x in ipairs(xs or {}) do
          refty(x.type)
        end
      end
      for _, v in pairs(require('build.data.products.' .. p .. '.apis')) do
        reflist(v.inputs)
        reflist(v.outputs)
      end
      for _, v in pairs(require('build.data.products.' .. p .. '.events')) do
        for _, pv in ipairs(v.payload) do
          refty(pv.type)
        end
      end
      for _, v in pairs(require('build.data.products.' .. p .. '.structures')) do
        for _, f in pairs(v.fields) do
          refty(f.type)
        end
      end
      for _, v in pairs(require('build.data.products.' .. p .. '.uiobjects')) do
        for _, f in pairs(v.fields) do
          refty(f.type)
        end
        for _, m in pairs(v.methods) do
          reflist(m.inputs)
          reflist(m.outputs)
        end
      end
      local actual = require('build.data.products.' .. p .. '.stringenums')
      for k in pairs(actual) do
        it(k, function()
          assert.True(used[k])
        end)
      end
    end)
  end
end)
