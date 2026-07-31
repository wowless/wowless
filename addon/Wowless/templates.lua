local _, G = ...
G.testsuite.templates = function()
  local check1 = G.check1
  local retn = G.retn

  local function checkBoth(obj)
    check1(true, obj.apiTemplateFrom1)
    check1(true, obj.apiTemplateFrom2)
  end

  return {
    -- CreateFrame splits its template argument on commas and/or spaces
    -- (wowless/modules/api.lua), applying every named template in order.
    -- Confirmed against a real client to work the same way.
    -- CreateForbiddenFrame is not addon-accessible, so it isn't tested
    -- separately; assume it behaves like CreateFrame.
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

    -- Frame:CreateTexture/CreateFontString/CreateLine/CreateMaskTexture all
    -- go through api.CreateChildUIObject, which splits templateName the
    -- same way CreateFrame does. Confirmed against a real client that this
    -- is wrong for all four: the client treats the whole templateName
    -- string as one literal name, so a comma-separated list just fails to
    -- match any template and errors.
    CreateTexture = function()
      return {
        ['comma-separated templates'] = function()
          local f = CreateFrame('Frame')
          local names = 'WowlessApiTemplateTexture1,WowlessApiTemplateTexture2'
          if _G.__wowless then
            checkBoth(retn(1, f:CreateTexture(nil, nil, names)))
          else
            check1(false, (pcall(f.CreateTexture, f, nil, nil, names)))
          end
        end,
      }
    end,

    CreateFontString = function()
      return {
        ['comma-separated templates'] = function()
          local f = CreateFrame('Frame')
          local names = 'WowlessApiTemplateFontString1,WowlessApiTemplateFontString2'
          if _G.__wowless then
            checkBoth(retn(1, f:CreateFontString(nil, nil, names)))
          else
            check1(false, (pcall(f.CreateFontString, f, nil, nil, names)))
          end
        end,
      }
    end,

    CreateLine = function()
      return {
        ['comma-separated templates'] = function()
          local f = CreateFrame('Frame')
          local names = 'WowlessApiTemplateLine1,WowlessApiTemplateLine2'
          if _G.__wowless then
            checkBoth(retn(1, f:CreateLine(nil, nil, names)))
          else
            check1(false, (pcall(f.CreateLine, f, nil, nil, names)))
          end
        end,
      }
    end,

    CreateMaskTexture = function()
      return {
        ['comma-separated templates'] = function()
          local f = CreateFrame('Frame')
          local names = 'WowlessApiTemplateMaskTexture1,WowlessApiTemplateMaskTexture2'
          if _G.__wowless then
            checkBoth(retn(1, f:CreateMaskTexture(nil, nil, names)))
          else
            check1(false, (pcall(f.CreateMaskTexture, f, nil, nil, names)))
          end
        end,
      }
    end,

    -- Region/CreateAnimationGroup.lua ignores every argument beyond self
    -- (it doesn't even accept a name), so templateName is never looked up
    -- or applied -- not even a single valid name.
    CreateAnimationGroup = function()
      return {
        ['single template'] = function()
          local f = CreateFrame('Frame')
          local g = retn(1, f:CreateAnimationGroup(nil, 'WowlessApiTemplateAnimationGroup1'))
          if _G.__wowless then
            check1('NONE', (g:GetLooping()))
          else
            check1('REPEAT', (g:GetLooping()))
          end
        end,
        ['comma-separated templates'] = function()
          local f = CreateFrame('Frame')
          local names = 'WowlessApiTemplateAnimationGroup1,WowlessApiTemplateAnimationGroup2'
          if _G.__wowless then
            local g = retn(1, f:CreateAnimationGroup(nil, names))
            check1('NONE', (g:GetLooping()))
          else
            check1(false, (pcall(f.CreateAnimationGroup, f, nil, names)))
          end
        end,
      }
    end,

    -- AnimationGroup/CreateAnimation.lua only reads its first argument
    -- (animationType); name and templateName are accepted but discarded,
    -- so not even a single valid template name is applied.
    CreateAnimation = function()
      return {
        ['single template'] = function()
          local ag = CreateFrame('Frame'):CreateAnimationGroup()
          local a = retn(1, ag:CreateAnimation('Animation', nil, 'WowlessApiTemplateAnimation1'))
          if _G.__wowless then
            check1('NONE', (a:GetSmoothing()))
          else
            check1('IN', (a:GetSmoothing()))
          end
        end,
        ['comma-separated templates'] = function()
          local ag = CreateFrame('Frame'):CreateAnimationGroup()
          local names = 'WowlessApiTemplateAnimation1,WowlessApiTemplateAnimation2'
          if _G.__wowless then
            local a = retn(1, ag:CreateAnimation('Animation', nil, names))
            check1('NONE', (a:GetSmoothing()))
          else
            check1(false, (pcall(ag.CreateAnimation, ag, 'Animation', nil, names)))
          end
        end,
      }
    end,

    -- ModelScene/CreateActor.lua looks up its template argument as a
    -- single literal name (no splitting), so a comma-separated list is
    -- just an unknown template name and errors. Confirmed against a real
    -- client to work the same way.
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
