describe('uiobjectimpl', function()
  local luas = {}
  for _, f in ipairs(require('wowless.util').getfiles('data/uiobjects')) do
    luas[f] = assert(require('pl.file').read(f))
  end
  it('references all the files in data/uiobjects', function()
    local expected = {}
    for k, v in pairs(require('build.data.uiobjectimpl')) do
      if v.luafile then
        expected['data/uiobjects/' .. k .. '.lua'] = true
      end
    end
    local actual = {}
    for f in pairs(luas) do
      actual[f] = true
    end
    assert.same(expected, actual)
  end)
  it('references exactly the set of all implemented apis', function()
    local expected = {}
    for k in pairs(require('build.data.uiobjectimpl')) do
      expected[k] = true
    end
    local actual = {}
    for _, p in ipairs(require('build.data.products')) do
      for _, v in pairs(require('build.data.products.' .. p .. '.uiobjects')) do
        for _, vv in pairs(v.methods) do
          if vv.impl and vv.impl.uiobjectimpl then
            actual[vv.impl.uiobjectimpl] = true
          end
        end
      end
    end
    assert.same(expected, actual)
  end)
  for filename, content in pairs(luas) do
    describe(filename, function()
      it('loads', function()
        assert(loadstring(content, '@' .. filename))
      end)
    end)
  end
end)
