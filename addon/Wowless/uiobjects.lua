local addonName, G = ...
G.testsuite.uiobjects = function()
  local assertEquals = G.assertEquals
  local check0 = G.check0
  local check1 = G.check1
  local check2 = G.check2
  local check3 = G.check3
  local check4 = G.check4
  local check6 = G.check6
  local match = G.match
  local retn = G.retn
  return {
    Animation = function()
      return {
        target = function()
          local f = CreateFrame('Frame')
          local a = f:CreateAnimationGroup():CreateAnimation()
          check1(f, a:GetTarget())
          assertEquals(false, pcall(a.SetTarget, a))
          assertEquals(false, pcall(a.SetTarget, a, nil))
        end,
      }
    end,

    Frame = function()
      return {
        ['attributes'] = function()
          local attrs = {
            a = 'va',
            aa = 'vaa',
            aaa = 'vaaa',
          }
          local f = CreateFrame('Frame')
          for k, v in pairs(attrs) do
            local t, n
            check0(f:SetScript('OnAttributeChanged', function(...)
              t, n = { ... }, select('#', ...)
            end))
            check0(f:SetAttribute(k, v))
            assertEquals(3, n)
            check3(f, k, v, unpack(t, 1, 3))
            check0(f:SetScript('OnAttributeChanged', nil))
          end
          local real = not _G.__wowless -- issue #429
          local err = 'Arguments: ("name")\nLua Taint: ' .. addonName
          local function happy(v, ...)
            local t, n = { ... }, select('#', ...)
            return function()
              return match(1, v, f:GetAttribute(unpack(t, 1, n)))
            end
          end
          local function errcase(...)
            local t, n = { ... }, select('#', ...)
            return function()
              if real then
                return match(2, false, err, pcall(f.GetAttribute, f, unpack(t, 1, n)))
              else
                local success, msg = pcall(f.GetAttribute, f, unpack(t, 1, n))
                assertEquals(false, success)
                assertEquals(false, msg == err)
              end
            end
          end
          return {
            a = happy('va', 'a'),
            aa = happy('vaa', 'aa'),
            aaa = happy('vaaa', 'aaa'),
            allnil = errcase(nil, nil, nil),
            extranil = happy('va', 'a', nil),
            justnil = errcase(nil),
            justpost = errcase(nil, nil, 'a'),
            justpre = happy('va', 'a', nil, nil),
            noarg = errcase(),
            preaa = happy(real and 'vaa' or 'va', 'a', 'a', nil),
            prepostaaa = happy(real and 'vaaa' or 'va', 'a', 'a', 'a'),
            postaa = real and happy('vaa', nil, 'a', 'a') or errcase(nil, 'a', 'a'),
            threearg = real and happy('va', nil, 'a', nil) or errcase(nil, 'a', nil),
            twoargoutofthree = errcase(nil, 'a'),
          }
        end,
        ['creation with frame in name position'] = function()
          local f = CreateFrame('Frame')
          local g = CreateFrame('Frame', f)
          assert(g:GetName() == nil)
          assert(g:GetParent() == nil)
        end,
        ['creation with number name'] = function()
          assertEquals(nil, _G['999'])
          local f = retn(1, CreateFrame('Frame', 999))
          check1('999', f:GetName())
          assertEquals(f, _G['999'])
        end,
        ['does not overflow the stack when OnShow/OnHide call themselves'] = function()
          local f = retn(1, CreateFrame('Frame'))
          check0(f:SetScript('OnShow', function(self)
            self:Show()
          end))
          check0(f:SetScript('OnHide', function(self)
            self:Hide()
          end))
          check0(f:Hide())
          check0(f:Show())
        end,
        ['gets a new script handler when hooked'] = function()
          local f = retn(1, CreateFrame('frame'))
          check0(f:SetScript('OnShow', function() end))
          local h = retn(1, f:GetScript('OnShow'))
          check1(true, f:HookScript('OnShow', function() end))
          assert(h ~= retn(1, f:GetScript('OnShow')))
        end,
        ['handles show/hide across three generations'] = function()
          local a = retn(1, CreateFrame('Frame'))
          local b = retn(1, CreateFrame('Frame', nil, a))
          local c = retn(1, CreateFrame('Frame', nil, b))
          local function state()
            return a:IsShown(), a:IsVisible(), b:IsShown(), b:IsVisible(), c:IsShown(), c:IsVisible()
          end
          check6(true, true, true, true, true, true, state())
          b:Hide()
          check6(true, true, false, false, true, false, state())
          c:Show()
          check6(true, true, false, false, true, false, state())
          c:Hide()
          check6(true, true, false, false, false, false, state())
          a:Show()
          check6(true, true, false, false, false, false, state())
          b:Show()
          check6(true, true, true, true, false, false, state())
          c:Show()
          check6(true, true, true, true, true, true, state())
          a:Hide()
          check6(false, false, true, false, true, false, state())
        end,
        ['has expected defaults'] = function()
          local f = CreateFrame('Frame')
          check1(0, f:GetHeight())
          check1(0, f:GetNumPoints())
          check1(true, f:IsShown())
          check2(0, 0, f:GetSize())
          check1(true, f:IsVisible())
          check1(0, f:GetWidth())
        end,
        ['kid order'] = function()
          return {
            ['three'] = function()
              local f = CreateFrame('Frame')
              local g = CreateFrame('Frame', nil, f)
              local h = CreateFrame('Frame', nil, f)
              local i = CreateFrame('Frame', nil, f)
              check1(3, f:GetNumChildren())
              check3(g, h, i, f:GetChildren())
              h:SetParent(nil)
              check1(2, f:GetNumChildren())
              check2(g, i, f:GetChildren())
              h:SetParent(f)
              check1(3, f:GetNumChildren())
              check3(g, i, h, f:GetChildren())
            end,
            ['two'] = function()
              local f = CreateFrame('Frame')
              local g = CreateFrame('Frame')
              local h = CreateFrame('Frame')
              g:SetParent(f)
              h:SetParent(f)
              check1(2, f:GetNumChildren())
              check2(g, h, f:GetChildren())
              g:SetParent(f)
              check1(2, f:GetNumChildren())
              check2(g, h, f:GetChildren())
            end,
          }
        end,
        ['level'] = function()
          local f = CreateFrame('Frame')
          local g = CreateFrame('Frame')
          local h = CreateFrame('Frame')
          assertEquals(0, f:GetFrameLevel())
          g:SetParent(f)
          assertEquals(1, g:GetFrameLevel())
          f:SetFrameLevel(5)
          assertEquals(5, f:GetFrameLevel())
          assertEquals(6, g:GetFrameLevel())
          f:SetParent(h)
          assertEquals(0, h:GetFrameLevel())
          assertEquals(1, f:GetFrameLevel())
          assertEquals(2, g:GetFrameLevel())
          f:SetParent(nil)
          f:SetFrameLevel(42)
          assertEquals(false, f:HasFixedFrameLevel())
          f:SetFixedFrameLevel(true)
          assertEquals(true, f:HasFixedFrameLevel())
          assertEquals(42, f:GetFrameLevel())
          assertEquals(43, g:GetFrameLevel())
          f:SetParent(h)
          assertEquals(42, f:GetFrameLevel())
          assertEquals(43, g:GetFrameLevel())
          f:SetFixedFrameLevel(false)
          assertEquals(false, f:HasFixedFrameLevel())
          assertEquals(42, f:GetFrameLevel())
          assertEquals(43, g:GetFrameLevel())
          f:SetParent(h)
          assertEquals(42, f:GetFrameLevel())
          assertEquals(43, g:GetFrameLevel())
          f:SetParent(nil)
          f:SetParent(h)
          assertEquals(1, f:GetFrameLevel())
          assertEquals(2, g:GetFrameLevel())
        end,
        ['OnShow/OnHide mutual recursion terminates'] = function()
          if _G.__wowless then -- TODO remove this
            return
          end
          local log = {}
          local f = retn(1, CreateFrame('Frame'))
          check0(f:SetScript('OnShow', function(self)
            table.insert(log, self:IsVisible() and 'A' or 'a')
            self:Hide()
            table.insert(log, self:IsVisible() and 'B' or 'b')
          end))
          check0(f:SetScript('OnHide', function(self)
            table.insert(log, self:IsVisible() and 'C' or 'c')
            self:Show()
            table.insert(log, self:IsVisible() and 'D' or 'd')
          end))
          check1(true, f:IsVisible())
          check0(f:Hide())
          check1(false, f:IsVisible())
          check1(('cDAb'):rep(6), table.concat(log))
        end,
        ['parent keys'] = function()
          local up = CreateFrame('Frame')
          local down = CreateFrame('Frame', nil, up)
          check1(nil, down:GetParentKey())
          up.moo = down
          check1('moo', down:GetParentKey())
          check0(down:SetParentKey('cow'))
          assertEquals(down, up.cow)
          assertEquals(down, up.moo)
          check1('moo', down:GetParentKey())
          check0(down:SetParentKey('cow', true))
          assertEquals(down, up.cow)
          if up.ClearParentKey then
            assertEquals(nil, up.moo)
          else
            assertEquals(down, up.moo)
            up.moo = nil
          end
          check1('cow', down:GetParentKey())
          up.cow = nil
          check1(nil, down:GetParentKey())
        end,
        ['support $parent in frame names'] = function()
          local moo = retn(1, CreateFrame('Frame', 'WowlessParentNameTestMoo'))
          local mooCow = retn(1, CreateFrame('Frame', '$parentWowlessCow', moo))
          local topCow = retn(1, CreateFrame('Frame', '$parentWowlessCow'))
          return {
            substitution = function()
              local name = 'WowlessParentNameTestMooWowlessCow'
              check1(name, mooCow:GetName())
              assertEquals(mooCow, _G[name])
            end,
            top = function()
              local name = 'TopWowlessCow'
              check1(name, topCow:GetName())
              assertEquals(topCow, _G[name])
            end,
          }
        end,
      }
    end,

    GameTooltip = function()
      local f = G.retn
      return {
        init = function()
          local gt = f(1, CreateFrame('GameTooltip'))
          return {
            GetAnchorType = function()
              assertEquals('ANCHOR_', f(1, gt:GetAnchorType()):sub(1, 7))
            end,
            GetChildren = function()
              f(0, gt:GetChildren())
            end,
            GetNumChildren = function()
              assertEquals(0, f(1, gt:GetNumChildren()))
            end,
            GetNumRegions = function()
              assertEquals(0, f(1, gt:GetNumRegions()))
            end,
            GetOwner = function()
              assertEquals(nil, f(1, gt:GetOwner()))
            end,
            GetRegions = function()
              f(0, gt:GetRegions())
            end,
            NumLines = function()
              assertEquals(0, f(1, gt:NumLines()))
            end,
          }
        end,
        SetOwner = function()
          return {
            AnchorTypes = function()
              local gt = f(1, CreateFrame('GameTooltip'))
              local owner = f(1, CreateFrame('Frame'))
              local anchorTypes = {
                'ANCHOR_BOTTOM',
                'ANCHOR_BOTTOMLEFT',
                'ANCHOR_BOTTOMRIGHT',
                'ANCHOR_CURSOR',
                'ANCHOR_LEFT',
                'ANCHOR_NONE',
                'ANCHOR_PRESERVE',
                'ANCHOR_RIGHT',
                'ANCHOR_TOP',
                'ANCHOR_TOPLEFT',
                'ANCHOR_TOPRIGHT',
              }
              local tests = {}
              for _, anchorType in ipairs(anchorTypes) do
                tests[anchorType] = function()
                  f(0, gt:SetOwner(owner, anchorType))
                  assertEquals(anchorType, f(1, gt:GetAnchorType()))
                end
              end
              return tests
            end,
            InvalidAnchorType = function()
              local gt = f(1, CreateFrame('GameTooltip'))
              local owner = f(1, CreateFrame('Frame'))
              f(0, gt:SetOwner(owner, 'invalid'))
              assertEquals('ANCHOR_LEFT', f(1, gt:GetAnchorType()))
            end,
            NoArgs = function()
              local gt = f(1, CreateFrame('GameTooltip'))
              assertEquals(false, pcall(gt.SetOwner, gt))
            end,
            OneArg = function()
              local gt = f(1, CreateFrame('GameTooltip'))
              local owner = f(1, CreateFrame('Frame'))
              f(0, gt:SetOwner(owner))
              return {
                GetAnchorType = function()
                  assertEquals('ANCHOR_LEFT', f(1, gt:GetAnchorType()))
                end,
                GetOwner = function()
                  assertEquals(owner, f(1, gt:GetOwner()))
                end,
                IsOwned = function()
                  assertEquals(true, f(1, gt:IsOwned(owner)))
                end,
              }
            end,
          }
        end,
      }
    end,

    Scale = function()
      return {
        origin = function()
          local s = CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Scale')
          check3('CENTER', 0, 0, s:GetOrigin())
          assertEquals(false, pcall(s.SetOrigin))
          assertEquals(false, pcall(s.SetOrigin, 'garbage', 20, 30))
          assertEquals(false, pcall(s.SetOrigin, 'LEFT'))
          assertEquals(false, pcall(s.SetOrigin, 'LEFT', 20))
          check0(s:SetOrigin('LEFT', 20, 30))
          check3('LEFT', 20, 30, s:GetOrigin())
        end,
      }
    end,

    ScrollFrame = function()
      return {
        SetScrollChild = function()
          local f = CreateFrame('ScrollFrame')
          assertEquals(nil, f:GetScrollChild())
          local g = CreateFrame('Frame', 'WowlessScrollFrameChild')
          f:SetScrollChild(g)
          assertEquals(g, f:GetScrollChild())
          assertEquals(f, g:GetParent())
          assertEquals(false, pcall(f.SetScrollChild, f, nil))
          assertEquals(false, pcall(f.SetScrollChild, f, 'WowlessScrollFrameChild'))
          assertEquals(false, pcall(f.SetScrollChild, f))
        end,
      }
    end,

    Slider = function()
      local s = CreateFrame('Slider')
      assertEquals(nil, s:GetThumbTexture())
      local t = s:CreateTexture()
      s:SetThumbTexture(t)
      assertEquals(t, s:GetThumbTexture())
      s:SetThumbTexture(12345)
      assertEquals(t, s:GetThumbTexture())
      assertEquals(12345, t:GetTexture())
    end,

    Texture = function()
      return {
        SetColorTexture = function()
          local colortex = _G.WowlessData.Build.test and 'FileData ID 0' or nil
          local t = CreateFrame('Frame'):CreateTexture()
          assertEquals('BLEND', t:GetBlendMode())
          t:SetColorTexture(0.8, 0.6, 0.4, 0.2)
          assertEquals(colortex, t:GetTexture())
          check4(1, 1, 1, 1, t:GetVertexColor())
          t:SetTexture(136235)
          assertEquals(136235, t:GetTexture())
          t:SetColorTexture(0.8, 0.6, 0.4, 0.2)
          assertEquals(colortex, t:GetTexture())
        end,
        SetDrawLayer = function()
          local t = CreateFrame('Frame'):CreateTexture()
          check2('ARTWORK', 0, t:GetDrawLayer())
          check0(t:SetDrawLayer('ARTWORK', 5))
          check2('ARTWORK', 5, t:GetDrawLayer())
          check0(t:SetDrawLayer('ARTWORK'))
          check2('ARTWORK', 0, t:GetDrawLayer())
        end,
      }
    end,
  }
end
