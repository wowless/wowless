describe('addon #small', function()
  local versions = {
    'Vanilla',
    'TBC',
    'Mainline',
  }
  for _, version in ipairs(versions) do
    describe(version, function()
      it('writes a log on PLAYER_LOGOUT', function()
        local api = require('wowless.api').new(function(level, ...)
          if level == 0 then
            print(string.format(...))
          end
        end)
        local loader = require('wowless.loader').loader(api, {
          version = version,
        })
        require('wowless.env').init(api, loader)
        loader.loadToc(('addon/Wowless/Wowless_%s.toc'):format(version))
        api.SendEvent('PLAYER_LOGIN')
        api.SendEvent('PLAYER_LOGOUT')
        local expected = {
          'OnLoad(WowlessSimpleFrame,none)',
          'OnShow(WowlessSimpleFrame,none)',
          'OnLoad(WowlessAttributeFrame,none)',
          'OnShow(WowlessAttributeFrame,none)',
          'OnLoad(WowlessHiddenFrame,none)',
          'OnLoad(WowlessParentKid2,WowlessParent)',
          'OnShow(WowlessParentKid2,WowlessParent)',
          'OnLoad(WowlessParentKid1,WowlessParent)',
          'OnShow(WowlessParentKid1,WowlessParent)',
          'OnLoad(WowlessParent,none)',
          'OnShow(WowlessParent,none)',
          'OnLoad(WowlessKeyParent,none)',
          'OnShow(WowlessKeyParent,none)',
          'OnLoad(WowlessKeyParentKid1,WowlessKeyParent)',
          'OnShow(WowlessKeyParentKid1,WowlessKeyParent)',
          'OnLoad(WowlessKeyParentKid2,WowlessKeyParent)',
          'OnShow(WowlessKeyParentKid2,WowlessKeyParent)',
          'before WowlessLuaFrame',
          'OnLoad(WowlessLuaFrame,none)',
          'OnShow(WowlessLuaFrame,none)',
          'after WowlessLuaFrame',
        }
        assert.same(0, api.GetErrorCount())
        assert.same(expected, api.env.WowlessLog)
      end)
    end)
  end
end)
