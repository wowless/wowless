describe('xml.lua', function()
  local module = dofile('xml.lua')
  local handle = io.popen('find wowui/classic/{SharedXML,FrameXML,AddOns} -name "*.xml"')
  local warnings = {}
  for line in handle:lines() do
    it('handles ' .. line, function()
      local w = module.validate(line)
      warnings[line] = next(w) and w or nil
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
