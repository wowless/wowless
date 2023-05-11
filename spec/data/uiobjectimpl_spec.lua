describe('uiobjectimpl', function()
  it('has the right files', function()
    local expected = {}
    for k in pairs(require('build/data/uiobjectimpl')) do
      expected['data/uiobjects/' .. k .. '.lua'] = true
    end
    local actual = {}
    for _, f in ipairs(require('pl.dir').getallfiles('data/uiobjects')) do
      actual[f] = true
    end
    assert.same(expected, actual)
  end)
end)
