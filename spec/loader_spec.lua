describe('loader #small', function()

  local api, loader
  before_each(function()
    api = require('wowless.api').new(function() end)
    require('wowless.env').init(api)
    loader = require('wowless.loader').loader(api)
  end)

  local function loadXml(str)
    loader.loadXml('test.xml', str)
  end

  it('loads empty xml', function()
    loadXml('<Ui />')
    assert.same(0, api.GetErrorCount())
  end)

  it('treats bad xml as an error', function()
    loadXml('<Ui>')
    assert.same(1, api.GetErrorCount())
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

  it('calls OnLoad script function', function()
    api.env.MyOnLoad = function(self)
      self.moo = 'cow'
    end
    loadXml([[
      <Ui>
        <Frame name='MyFrame'>
          <Scripts>
            <OnLoad function='MyOnLoad' />
          </Scripts>
        </Frame>
      </Ui>
    ]])
    assert.same(0, api.GetErrorCount())
    assert.same({ moo = 'cow' }, api.env.MyFrame)
  end)

  it('calls OnLoad script inline', function()
    loadXml([[
      <Ui>
        <Frame name='MyFrame'>
          <Scripts>
            <OnLoad>
              self.moo = 'cow'
            </OnLoad>
          </Scripts>
        </Frame>
      </Ui>
    ]])
    assert.same(0, api.GetErrorCount())
    assert.same({ moo = 'cow' }, api.env.MyFrame)
  end)

  it('calls OnLoad of kids before parents', function()
    local log = {}
    api.env.Logger_OnLoad = function(self)
      table.insert(log, self:GetName())
    end
    loadXml([[
      <Ui>
        <Frame name='Logger' virtual='true'>
          <Scripts>
            <OnLoad function='Logger_OnLoad' />
          </Scripts>
        </Frame>
        <Frame name='Frame1' inherits='Logger'>
          <Frames>
            <Frame name='Frame2' inherits='Logger'>
              <Frames>
                <Frame name='Frame3' inherits='Logger' />
              </Frames>
            </Frame>
          </Frames>
        </Frame>
      </Ui>
    ]])
    assert.same(0, api.GetErrorCount())
    assert.same({'Frame3', 'Frame2', 'Frame1'}, log)
  end)

  it('runs parentKey and parentArray before parent OnLoad', function()
    local keyKid, arrayKid
    api.env.Frame1_OnLoad = function(self)
      keyKid = self.KeyKid
      arrayKid = self.ArrayKid
    end
    loadXml([[
      <Ui>
        <Frame name='Frame1'>
          <Scripts>
            <OnLoad function='Frame1_OnLoad' />
          </Scripts>
          <Frames>
            <Frame name='Frame2' parentKey='KeyKid' />
            <Frame name='Frame3' parentArray='ArrayKid' />
          </Frames>
        </Frame>
      </Ui>
    ]])
    assert.same(0, api.GetErrorCount())
    assert.equals(keyKid, api.env.Frame1.KeyKid)
    assert.equals(arrayKid, api.env.Frame1.ArrayKid)
    assert.equals(keyKid, api.env.Frame2)
    assert.same(1, #arrayKid)
    assert.equals(arrayKid[1], api.env.Frame3)
  end)

  it('runs OnShow on new non-hidden frames', function()
    local log = {}
    for _, h in ipairs({'OnLoad', 'OnShow', 'OnHide'}) do
      api.env['Logger_' .. h] = function(self)
        table.insert(log, h .. ' ' .. self:GetName())
      end
    end
    loadXml([[
      <Ui>
        <Frame name='Logger' virtual='true'>
          <Scripts>
            <OnLoad function='Logger_OnLoad' />
            <OnShow function='Logger_OnShow' />
            <OnHide function='Logger_OnHide' />
          </Scripts>
        </Frame>
        <Frame name='Frame1' inherits='Logger' />
        <Frame name='Frame2' inherits='Logger' hidden='true' />
        <Frame name='Frame3' inherits='Logger' hidden='false' />
      </Ui>
    ]])
    local expected = {
      'OnLoad Frame1',
      'OnShow Frame1',
      'OnLoad Frame2',
      'OnLoad Frame3',
      'OnShow Frame3',
    }
    assert.same(expected, log)
  end)
end)
