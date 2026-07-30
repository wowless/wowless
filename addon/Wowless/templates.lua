local _, G = ...
G.testsuite.templates = function()
  local assertEquals = G.assertEquals
  local check1 = G.check1
  local retn = G.retn

  local function checkBoth(obj)
    check1(true, obj.apiTemplateFrom1)
    check1(true, obj.apiTemplateFrom2)
  end

  return {
    -- CreateFrame splits its template argument on commas and/or spaces
    -- (wowless/modules/api.lua), applying every named template in order.
    CreateFrame = function()
      return {
        ['single template'] = function()
          local f = retn(1, CreateFrame('Frame', nil, nil, 'WowlessApiTemplateFrame1'))
          check1(true, f.apiTemplateFrom1)
        end,
        ['comma-separated templates'] = function()
          checkBoth(retn(1, CreateFrame('Frame', nil, nil, 'WowlessApiTemplateFrame1,WowlessApiTemplateFrame2')))
        end,
        ['comma-space-separated templates'] = function()
          checkBoth(retn(1, CreateFrame('Frame', nil, nil, 'WowlessApiTemplateFrame1, WowlessApiTemplateFrame2')))
        end,
      }
    end,

    -- CreateForbiddenFrame currently just delegates straight to CreateFrame
    -- (see wowless/modules/api.lua, "-- TODO implement properly"), so it
    -- exercises the same comma-splitting behavior for now.
    CreateForbiddenFrame = function()
      return {
        ['comma-separated templates'] = function()
          local f =
            retn(1, _G.CreateForbiddenFrame('Frame', nil, nil, 'WowlessApiTemplateFrame1,WowlessApiTemplateFrame2'))
          checkBoth(f)
        end,
      }
    end,

    -- Frame:CreateTexture/CreateFontString/CreateLine/CreateMaskTexture all
    -- go through api.CreateChildUIObject, which splits templateName the
    -- same way CreateFrame does. Real-client testing has shown that
    -- CreateTexture rejects a comma-separated templateName outright, so
    -- this is a known wowless/real-client divergence, not just a
    -- hypothetical one.
    CreateTexture = function()
      return {
        ['comma-separated templates'] = function()
          local f = CreateFrame('Frame')
          local t = retn(1, f:CreateTexture(nil, nil, 'WowlessApiTemplateTexture1,WowlessApiTemplateTexture2'))
          checkBoth(t)
        end,
      }
    end,

    CreateFontString = function()
      return {
        ['comma-separated templates'] = function()
          local f = CreateFrame('Frame')
          local fs =
            retn(1, f:CreateFontString(nil, nil, 'WowlessApiTemplateFontString1,WowlessApiTemplateFontString2'))
          checkBoth(fs)
        end,
      }
    end,

    CreateLine = function()
      return {
        ['comma-separated templates'] = function()
          local f = CreateFrame('Frame')
          local l = retn(1, f:CreateLine(nil, nil, 'WowlessApiTemplateLine1,WowlessApiTemplateLine2'))
          checkBoth(l)
        end,
      }
    end,

    CreateMaskTexture = function()
      return {
        ['comma-separated templates'] = function()
          local f = CreateFrame('Frame')
          local m =
            retn(1, f:CreateMaskTexture(nil, nil, 'WowlessApiTemplateMaskTexture1,WowlessApiTemplateMaskTexture2'))
          checkBoth(m)
        end,
      }
    end,

    -- Region/CreateAnimationGroup.lua ignores every argument beyond self
    -- (it doesn't even accept a name), so the templateName the yaml
    -- documents is not wired up at all yet -- comma-separated or not.
    CreateAnimationGroup = function()
      return {
        ['comma-separated templates do not error'] = function()
          local g = retn(1, CreateFrame('Frame'):CreateAnimationGroup('Bogus1,Bogus2'))
          assertEquals('AnimationGroup', g:GetObjectType())
        end,
      }
    end,

    -- AnimationGroup/CreateAnimation.lua only reads its first argument
    -- (animationType); name and templateName are accepted but discarded.
    CreateAnimation = function()
      return {
        ['comma-separated templates do not error'] = function()
          local ag = CreateFrame('Frame'):CreateAnimationGroup()
          local a = retn(1, ag:CreateAnimation('Animation', nil, 'Bogus1,Bogus2'))
          assertEquals('Animation', a:GetObjectType())
        end,
      }
    end,

    -- Path/CreateControlPoint.lua reads name but discards templateName.
    CreateControlPoint = function()
      return {
        ['comma-separated templates do not error'] = function()
          local path = retn(1, CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Path'))
          local point = retn(1, path:CreateControlPoint(nil, 'Bogus1,Bogus2'))
          assertEquals('ControlPoint', point:GetObjectType())
        end,
      }
    end,

    -- ModelScene/CreateActor.lua looks up its template argument as a
    -- single literal name (no splitting), so a comma-separated list is
    -- just an unknown template name and errors.
    CreateActor = function()
      return {
        ['single template'] = function()
          local scene = retn(1, CreateFrame('ModelScene'))
          local actor = retn(1, scene:CreateActor(nil, 'WowlessApiTemplateActor1'))
          check1(true, actor.apiTemplateFrom1)
        end,
        ['comma-separated templates error'] = function()
          local scene = retn(1, CreateFrame('ModelScene'))
          check1(false, (pcall(scene.CreateActor, scene, nil, 'WowlessApiTemplateActor1,WowlessApiTemplateActor2')))
        end,
      }
    end,
  }
end
