describe('loader #small', function()
  local api = require('wowless.api').new(function() end)
  require('wowless.env').init(api)
  local loader = require('wowless.loader').loader(api)

  local function loadXml(str)
    loader.loadXml('test.xml', str)
  end

  it('loads empty xml', function()
    loadXml('<Ui/>')
    assert.same(0, api.GetErrorCount())
  end)

  it('creates simple frames', function()
    loadXml([[
      <Ui>
        <Frame name='Frame1' />
        <Frame name='Frame2' />
      </Ui>
    ]])
    assert.same(0, api.GetErrorCount())
    local frame1 = api.env.Frame1
    local frame2 = api.env.Frame2
    assert.Not.Nil(frame1)
    assert.Not.Nil(frame2)
    assert.Not.equal(frame1, frame2)
  end)
end)
