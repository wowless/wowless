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
    -- go through api.CreateChildUIObject, which looks templateName up as a
    -- single literal name (no splitting), matching CreateActor's rule.
    -- Confirmed against a real client: a comma-separated list is just an
    -- unknown template name and errors.
    CreateTexture = function()
      return {
        ['single template'] = function()
          local f = CreateFrame('Frame')
          local t = retn(1, f:CreateTexture(nil, nil, 'WowlessApiTemplateTexture1'))
          check1(true, t.apiTemplateFrom1)
        end,
        ['comma-separated templates error'] = function()
          local f = CreateFrame('Frame')
          local names = 'WowlessApiTemplateTexture1,WowlessApiTemplateTexture2'
          check1(false, (pcall(f.CreateTexture, f, nil, nil, names)))
        end,
      }
    end,

    CreateFontString = function()
      return {
        ['single template'] = function()
          local f = CreateFrame('Frame')
          local fs = retn(1, f:CreateFontString(nil, nil, 'WowlessApiTemplateFontString1'))
          check1(true, fs.apiTemplateFrom1)
        end,
        ['comma-separated templates error'] = function()
          local f = CreateFrame('Frame')
          local names = 'WowlessApiTemplateFontString1,WowlessApiTemplateFontString2'
          check1(false, (pcall(f.CreateFontString, f, nil, nil, names)))
        end,
      }
    end,

    CreateLine = function()
      return {
        ['single template'] = function()
          local f = CreateFrame('Frame')
          local l = retn(1, f:CreateLine(nil, nil, 'WowlessApiTemplateLine1'))
          check1(true, l.apiTemplateFrom1)
        end,
        ['comma-separated templates error'] = function()
          local f = CreateFrame('Frame')
          local names = 'WowlessApiTemplateLine1,WowlessApiTemplateLine2'
          check1(false, (pcall(f.CreateLine, f, nil, nil, names)))
        end,
      }
    end,

    CreateMaskTexture = function()
      return {
        ['single template'] = function()
          local f = CreateFrame('Frame')
          local m = retn(1, f:CreateMaskTexture(nil, nil, 'WowlessApiTemplateMaskTexture1'))
          check1(true, m.apiTemplateFrom1)
        end,
        ['comma-separated templates error'] = function()
          local f = CreateFrame('Frame')
          local names = 'WowlessApiTemplateMaskTexture1,WowlessApiTemplateMaskTexture2'
          check1(false, (pcall(f.CreateMaskTexture, f, nil, nil, names)))
        end,
      }
    end,

    -- Region/CreateAnimationGroup.lua looks templateName up as a single
    -- literal name (no splitting), matching CreateActor's rule.
    CreateAnimationGroup = function()
      return {
        ['single template'] = function()
          local f = CreateFrame('Frame')
          local g = retn(1, f:CreateAnimationGroup(nil, 'WowlessApiTemplateAnimationGroup1'))
          check1('REPEAT', (g:GetLooping()))
        end,
        ['comma-separated templates error'] = function()
          local f = CreateFrame('Frame')
          local names = 'WowlessApiTemplateAnimationGroup1,WowlessApiTemplateAnimationGroup2'
          check1(false, (pcall(f.CreateAnimationGroup, f, nil, names)))
        end,
      }
    end,

    -- AnimationGroup/CreateAnimation.lua looks templateName up as a single
    -- literal name (no splitting), matching CreateActor's rule.
    CreateAnimation = function()
      return {
        ['single template'] = function()
          local ag = CreateFrame('Frame'):CreateAnimationGroup()
          local a = retn(1, ag:CreateAnimation('Animation', nil, 'WowlessApiTemplateAnimation1'))
          check1('IN', (a:GetSmoothing()))
        end,
        ['comma-separated templates error'] = function()
          local ag = CreateFrame('Frame'):CreateAnimationGroup()
          local names = 'WowlessApiTemplateAnimation1,WowlessApiTemplateAnimation2'
          check1(false, (pcall(ag.CreateAnimation, ag, 'Animation', nil, names)))
        end,
      }
    end,

    -- AnimationGroup/CreateAnimation.lua looks templateName up as a single
    -- literal name (no splitting), matching CreateActor's rule.
    CreateControlPoint = function()
      return {
        ['single template'] = function()
          local p = CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Path')
          local c = retn(1, p:CreateControlPoint(nil, 'WowlessApiTemplateControlPoint1'))
          check1('ControlPoint', c:GetObjectType())
        end,
        ['comma-separated templates error'] = function()
          local p = CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Path')
          local names = 'WowlessApiTemplateControlPoint1,WowlessApiTemplateControlPoint2'
          check1(false, (pcall(p.CreateControlPoint, p, nil, names)))
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
