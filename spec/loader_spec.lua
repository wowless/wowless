describe('loader #small', function()
  local api = require('wowless.api').new(function() end)
  local loader = require('wowless.loader').loader(api)

  local function loadXml(str)
    loader.loadXml('test.xml', str)
  end

  it('loads empty xml', function()
    loadXml('<Ui/>')
    assert.same(0, api.GetErrorCount())
  end)
end)
