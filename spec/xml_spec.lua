describe('xml.lua #huge', function()
  local module = require('wowless.xml')
  local handle = io.popen([[bash -c 'find wowui/classic/{SharedXML,FrameXML,AddOns} -name "*.xml"']])
  local warnings = {}
  local function check(e)
    assert.same('table', type(e))
    assert.same('string', type(e.name))
    assert.same('table', type(e.attr))
    assert.same('table', type(e.kids))
    for a, v in pairs(e.attr) do
      assert.same('string', type(a))
      local validator = ({
        boolean = function() end,
        number = function() end,
        string = function() end,
        table = function(t)
          for _, s in ipairs(t) do
            assert.same('string', type(s))
          end
        end,
      })[type(v)]
      assert.is_not.Nil(validator, 'unexpected type ' .. type(v))
      validator(v)
    end
    for _, k in ipairs(e.kids) do
      check(k)
    end
  end
  for line in handle:lines() do
    it('handles ' .. line, function()
      local r, w = module.validate(line)
      warnings[line] = next(w) and w or nil
      check(r)
    end)
  end
  handle:close()
  it('has known warnings', function()
    local known = {
      ['wowui/classic/AddOns/Blizzard_Commentator/Bindings.xml'] = {
        'ignoring text kid of bindings',
      },
      ['wowui/classic/AddOns/Blizzard_Commentator/Blizzard_CommentatorScoreboard.xml'] = {
        'attribute setToFinalAlpha is not supported by alpha',
        'attribute setToFinalAlpha is not supported by alpha',
      },
      ['wowui/classic/AddOns/Blizzard_Communities/CommunitiesInvitationFrame.xml'] = {
        'attribute relaitvePoint is not supported by anchor',
      },
      ['wowui/classic/AddOns/Blizzard_ItemSocketingUI/Blizzard_ItemSocketingUI.xml'] = {
        'ignoring text kid of frame',
      },
      ['wowui/classic/AddOns/Blizzard_SharedMapDataProviders/WorldQuestDataProvider.xml'] = {
        'attribute textureSubLevel is not supported by texture',
      },
      ['wowui/classic/AddOns/Blizzard_SocialUI/Blizzard_SocialUI.xml'] = {
        'ignoring text kid of texture',
      },
      ['wowui/classic/FrameXML/FriendsFrame.xml'] = {
        'attribute pointG is not supported by anchor',
      },
      ['wowui/classic/FrameXML/PetPaperDollFrame.xml'] = {
        'ignoring text kid of scripts',
        'ignoring text kid of scripts',
        'ignoring text kid of scripts',
        'ignoring text kid of scripts',
      },
      ['wowui/classic/FrameXML/WorldStateFrame.xml'] = {
        'ignoring text kid of scripts',
      },
    }
    assert.same(known, warnings)
  end)
end)
