describe('uiobjectimpl', function()
  local luas = {}
  for _, f in ipairs(require('pl.dir').getallfiles('data/uiobjects')) do
    luas[f] = assert(require('pl.file').read(f))
  end
  it('has the right files', function()
    local expected = {}
    for k in pairs(require('build.data.uiobjectimpl')) do
      expected['data/uiobjects/' .. k .. '.lua'] = true
    end
    local actual = {}
    for f in pairs(luas) do
      actual[f] = true
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
