local addonName, G = ...
G.testsuite.uiobjects = function()
  local assertEquals = G.assertEquals
  local check0 = G.check0
  local check1 = G.check1
  local check2 = G.check2
  local check3 = G.check3
  local check4 = G.check4
  local check5 = G.check5
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

    AnimationGroup = function()
      return {
        noqueuing = function()
          local a = CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('Animation')
          local depth = 0
          local log = {}
          a:SetScript('OnPlay', function(self)
            if depth < 5 then
              depth = depth + 1
              table.insert(log, 'a')
              self:Stop()
              table.insert(log, 'b')
            end
          end)
          a:SetScript('OnStop', function(self)
            table.insert(log, 'c')
            self:Play()
            table.insert(log, 'd')
          end)
          a:Play()
          check1(('ac'):rep(5) .. ('db'):rep(5), table.concat(log))
        end,
      }
    end,

    EditBox = function()
      return {
        fontobject = function()
          if _G.__wowless then
            return
          end
          local eb = CreateFrame('EditBox')
          eb:Hide()
          local fo = assert(retn(1, eb:GetFontObject()))
          local eb2 = CreateFrame('EditBox')
          eb2:Hide()
          local fo2 = assert(retn(1, eb2:GetFontObject()))
          assert(fo ~= fo2)
          check1('Font', fo:GetObjectType())
          check1(nil, fo:GetFontObject())
          check3(nil, 0, '', fo:GetFont())
          check1(fo, eb:GetFontObject())
          check0(eb:SetFontObject(fo2))
          check1(fo, eb:GetFontObject())
          assert(not pcall(eb.SetFontObject, eb, nil))
        end,
      }
    end,

    Font = function()
      return {
        loop0 = function()
          local font = CreateFont('WowlessFontObjectLoop0Test')
          local err = 'WowlessFontObjectLoop0Test:SetFontObject(): Can\'t create a font object loop'
          check2(false, err, pcall(font.SetFontObject, font, font))
        end,
        loop1 = function()
          local font1 = CreateFont('WowlessFontObjectLoop1Test1')
          local font2 = CreateFont('WowlessFontObjectLoop1Test2')
          check0(font2:SetFontObject(font1))
          local err = 'WowlessFontObjectLoop1Test1:SetFontObject(): Can\'t create a font object loop'
          check2(false, err, pcall(font1.SetFontObject, font1, font2))
        end,
        name = function()
          local name = 'WowlessFontObjectNameTest'
          local font1 = retn(1, CreateFont(name))
          assertEquals(font1, _G[name])
          check1(name, font1:GetName())
          check1(font1, CreateFont(name))
          _G[name] = nil
          check1(name, font1:GetName())
          check1(font1, CreateFont(name))
        end,
        noname = function()
          local usage = 'Usage: CreateFont("name")'
          check2(false, usage, pcall(CreateFont))
          check2(false, usage, pcall(CreateFont, nil))
        end,
        numbername = function()
          local n = 1759244889
          local s = tostring(n)
          local font = retn(1, CreateFont(n))
          assertEquals(nil, _G[n])
          assertEquals(font, _G[s])
          check1(s, font:GetName())
          assertEquals(font, retn(1, CreateFont(s)))
        end,
        vfs = function()
          if _G.__wowless then -- TODO support
            return
          end
          local font = CreateFont('WowlessFontObjectVfsTest')
          local fontname = ('Interface\\AddOns\\%s\\framework.lua'):format(addonName)
          check1(nil, font:GetFontObject())
          check3(nil, 0, '', font:GetFont())
          check0(font:SetFont(fontname, 12, ''))
          check1(nil, font:GetFontObject())
          check3(fontname, 12, '', font:GetFont())
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
              return match(2, false, err, pcall(f.GetAttribute, f, unpack(t, 1, n)))
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
            preaa = happy('vaa', 'a', 'a', nil),
            prepostaaa = happy('vaaa', 'a', 'a', 'a'),
            postaa = happy('vaa', nil, 'a', 'a'),
            threearg = happy('va', nil, 'a', nil),
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
          assertEquals(nil, up.moo)
          check1('cow', down:GetParentKey())
          up.cow = nil
          check1(nil, down:GetParentKey())
        end,
        ['parent keys and metamethods'] = function()
          local f = CreateFrame('Frame')
          local g = CreateFrame('Frame', nil, f)
          local mt, mk, mv
          setmetatable(f, {
            __newindex = function(t, k, v)
              mt = t
              mk = k
              mv = v
            end,
          })
          g:SetParentKey('moo')
          assertEquals(f, mt)
          assertEquals('moo', mk)
          assertEquals(g, mv)
          assertEquals(nil, f.moo)
        end,
        ['RegisterEventCallback accepts funtainer arg'] = function()
          local f = retn(1, CreateFrame('Frame'))
          if not f.RegisterEventCallback then
            return
          end
          local ft = _G.C_FunctionContainers.CreateCallback(function() end)
          return match(1, true, f:RegisterEventCallback('ENCOUNTER_STATE_CHANGED', ft))
        end,
        ['support $parent in frame names'] = function()
          local parent = retn(1, CreateFrame('Frame', 'WowlessParentNameTestMoo'))
          local t = {
            embeddedsubstitution = {
              arg = 'Wowless$parentCowSubstitution',
              name = 'Wowless$parentCowSubstitution',
              parent = parent,
            },
            embeddedtop = {
              arg = 'Wowless$parentCowTop',
              name = 'Wowless$parentCowTop',
            },
            ignoresanonsubtitution = {
              arg = '$parentIgnoreAnonSub',
              name = 'WowlessParentNameTestMooIgnoreAnonSub',
              parent = CreateFrame('Frame', nil, parent),
            },
            ignoresanontop = {
              arg = '$parentIgnoreAnonTop',
              name = 'TopIgnoreAnonTop',
              parent = CreateFrame('Frame'),
            },
            mixedcase = {
              arg = '$pArEnTMixed',
              name = 'WowlessParentNameTestMooMixed',
              parent = parent,
            },
            multisubstitution = {
              arg = '$parent$parentWowless$parentCow',
              name = 'WowlessParentNameTestMoo$parentWowless$parentCow',
              parent = parent,
            },
            multitop = {
              arg = '$parent$parentWowless$parentCow',
              name = 'Top$parentWowless$parentCow',
            },
            substitution = {
              arg = '$parentWowlessCow',
              name = 'WowlessParentNameTestMooWowlessCow',
              parent = parent,
            },
            top = {
              arg = '$parentWowlessCow',
              name = 'TopWowlessCow',
            },
          }
          local tests = {}
          for k, v in pairs(t) do
            tests[k] = function()
              local frame = retn(1, CreateFrame('Frame', v.arg, v.parent))
              check1(v.name, frame:GetName())
              assertEquals(frame, _G[v.name])
            end
          end
          return tests
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

    MessageFrame = function()
      return {
        fontobject = function()
          if _G.__wowless then
            return
          end
          local mf = CreateFrame('MessageFrame')
          mf:Hide()
          local fo = assert(retn(1, mf:GetFontObject()))
          local mf2 = CreateFrame('MessageFrame')
          mf2:Hide()
          local fo2 = assert(retn(1, mf2:GetFontObject()))
          assert(fo ~= fo2)
          check1('Font', fo:GetObjectType())
          check1(nil, fo:GetFontObject())
          check3(nil, 0, '', fo:GetFont())
          check1(fo, mf:GetFontObject())
          check0(mf:SetFontObject(fo2))
          check1(fo, mf:GetFontObject())
          assert(not pcall(mf.SetFontObject, mf, nil))
        end,
      }
    end,

    Region = function()
      return {
        points = function()
          return {
            dag = function()
              local function rstr(r)
                return tostring(r):gsub('^.*0x(.*)$', '%1')
              end
              return {
                ['0'] = function()
                  local f = CreateFrame('Frame')
                  local msg = table.concat({
                    'Action[SetPoint] failed because',
                    '[Cannot anchor to itself]: ',
                    'attempted from: Frame:SetPoint.',
                  })
                  check2(false, msg, pcall(f.SetPoint, f, 'CENTER', f))
                end,
                ['1'] = function()
                  local f = CreateFrame('Frame')
                  local g = CreateFrame('Frame')
                  local msg = table.concat({
                    'Action[SetPoint] failed because',
                    '[Cannot anchor to a region dependent on it]: ',
                    'attempted from: Frame:SetPoint.\n',
                    'Relative: [' .. rstr(g) .. ']\n',
                    'Dependent: [' .. rstr(g) .. ']',
                  })
                  check0(g:SetPoint('CENTER', f))
                  check2(false, msg, pcall(f.SetPoint, f, 'CENTER', g))
                end,
                ['2'] = function()
                  local f = CreateFrame('Frame')
                  local g = CreateFrame('Frame')
                  local h = CreateFrame('Frame')
                  local msg = table.concat({
                    'Action[SetPoint] failed because',
                    '[Cannot anchor to a region dependent on it]: ',
                    'attempted from: Frame:SetPoint.\n',
                    'Relative: [' .. rstr(h) .. ']\n',
                    'Dependent: [' .. rstr(g) .. ']\n',
                    'Dependent ancestors:\n',
                    '[' .. rstr(h) .. ']',
                  })
                  check0(g:SetPoint('CENTER', f))
                  check0(h:SetPoint('CENTER', g))
                  check2(false, msg, pcall(f.SetPoint, f, 'CENTER', h))
                end,
                ['3'] = function()
                  local f = CreateFrame('Frame')
                  local g = CreateFrame('Frame')
                  local h = CreateFrame('Frame')
                  local i = CreateFrame('Frame')
                  local msg = table.concat({
                    'Action[SetPoint] failed because',
                    '[Cannot anchor to a region dependent on it]: ',
                    'attempted from: Frame:SetPoint.\n',
                    'Relative: [' .. rstr(i) .. ']\n',
                    'Dependent: [' .. rstr(g) .. ']\n',
                    'Dependent ancestors:\n',
                    '[' .. rstr(h) .. ']\n',
                    '[' .. rstr(i) .. ']',
                  })
                  check0(g:SetPoint('CENTER', f))
                  check0(h:SetPoint('CENTER', g))
                  check0(i:SetPoint('CENTER', h))
                  check2(false, msg, pcall(f.SetPoint, f, 'CENTER', i))
                end,
                all0 = function()
                  local f = CreateFrame('Frame')
                  local msg = table.concat({
                    'Action[SetPoint] failed because',
                    '[Cannot anchor to itself]: ',
                    'attempted from: Frame:SetAllPoints.',
                  })
                  check2(false, msg, pcall(f.SetAllPoints, f, f))
                end,
                all3 = function()
                  local f = CreateFrame('Frame')
                  local g = CreateFrame('Frame')
                  local h = CreateFrame('Frame')
                  local i = CreateFrame('Frame')
                  local msg = table.concat({
                    'Action[SetPoint] failed because',
                    '[Cannot anchor to a region dependent on it]: ',
                    'attempted from: Frame:SetAllPoints.\n',
                    'Relative: [' .. rstr(i) .. ']\n',
                    'Dependent: [' .. rstr(g) .. ']\n',
                    'Dependent ancestors:\n',
                    '[' .. rstr(h) .. ']\n',
                    '[' .. rstr(i) .. ']',
                  })
                  check0(g:SetAllPoints(f))
                  check0(h:SetAllPoints(g))
                  check0(i:SetAllPoints(h))
                  check2(false, msg, pcall(f.SetAllPoints, f, i))
                end,
              }
            end,
          }
        end,
        ClearPoint = function()
          local f = CreateFrame('Frame')
          check0(f:SetPoint('TOPLEFT'))
          check0(f:SetPoint('TOPRIGHT'))
          check0(f:ClearPoint('TOP'))
          check1(2, f:GetNumPoints())
          check0(f:ClearPoint('TOPLEFT'))
          check1(1, f:GetNumPoints())
          check1('TOPRIGHT', (f:GetPoint(1)))
        end,
        GetPoint = function()
          local f = CreateFrame('Frame')
          f:SetPoint('TOPRIGHT')
          f:SetPoint('LEFT')
          f:SetPoint('BOTTOM')
          f:SetPoint('TOP')
          f:SetPoint('RIGHT')
          f:SetPoint('BOTTOMLEFT')
          f:SetPoint('CENTER')
          f:SetPoint('TOPLEFT')
          f:SetPoint('BOTTOMRIGHT')
          local function p(k, s)
            return function()
              return match(5, s, nil, s, 0, 0, f:GetPoint(k))
            end
          end
          return {
            num = function()
              return match(1, 9, f:GetNumPoints())
            end,
            p1 = p(1, 'TOPLEFT'),
            p2 = p(2, 'TOP'),
            p3 = p(3, 'TOPRIGHT'),
            p4 = p(4, 'LEFT'),
            p5 = p(5, 'CENTER'),
            p6 = p(6, 'RIGHT'),
            p7 = p(7, 'BOTTOMLEFT'),
            p8 = p(8, 'BOTTOM'),
            p9 = p(9, 'BOTTOMRIGHT'),
          }
        end,
        GetPointByName = function()
          local f = CreateFrame('Frame')
          check0(f:GetPointByName('CENTER'))
          check0(f:SetPoint('CENTER'))
          check5('CENTER', nil, 'CENTER', 0, 0, f:GetPointByName('CENTER'))
        end,
        IsCollapsed = function()
          local f = CreateFrame('Frame')
          local p = CreateFrame('Frame')
          p:Hide()
          local states = {
            ['hidden, will collapse, collapsed'] = function()
              check1(false, f:IsShown())
              check1(false, f:IsVisible())
              check1(true, f:CollapsesLayout())
              check1(true, f:IsCollapsed())
            end,
            ['hidden, will not collapse, not collapsed'] = function()
              check1(false, f:IsShown())
              check1(false, f:IsVisible())
              check1(false, f:CollapsesLayout())
              check1(false, f:IsCollapsed())
            end,
            ['invisible, will collapse, collapsed'] = function()
              check1(true, f:IsShown())
              check1(false, f:IsVisible())
              check1(true, f:CollapsesLayout())
              check1(true, f:IsCollapsed())
            end,
            ['invisible, will not collapse, not collapsed'] = function()
              check1(true, f:IsShown())
              check1(false, f:IsVisible())
              check1(false, f:CollapsesLayout())
              check1(false, f:IsCollapsed())
            end,
            ['shown, will collapse, not collapsed'] = function()
              check1(true, f:IsShown())
              check1(true, f:IsVisible())
              check1(true, f:CollapsesLayout())
              check1(false, f:IsCollapsed())
            end,
            ['shown, will not collapse, not collapsed'] = function()
              check1(true, f:IsShown())
              check1(true, f:IsVisible())
              check1(false, f:CollapsesLayout())
              check1(false, f:IsCollapsed())
            end,
          }
          local transitions = {
            hide = {
              edges = {
                ['shown, will collapse, not collapsed'] = 'hidden, will collapse, collapsed',
                ['shown, will not collapse, not collapsed'] = 'hidden, will not collapse, not collapsed',
              },
              func = function()
                check0(f:Hide())
              end,
            },
            setCollapsesLayoutFalse = {
              edges = {
                ['hidden, will collapse, collapsed'] = 'hidden, will not collapse, not collapsed',
                ['invisible, will collapse, collapsed'] = 'invisible, will not collapse, not collapsed',
                ['shown, will collapse, not collapsed'] = 'shown, will not collapse, not collapsed',
              },
              func = function()
                check0(f:SetCollapsesLayout(false))
              end,
            },
            setCollapsesLayoutTrue = {
              edges = {
                ['hidden, will not collapse, not collapsed'] = 'hidden, will collapse, collapsed',
                ['invisible, will not collapse, not collapsed'] = 'invisible, will collapse, collapsed',
                ['shown, will not collapse, not collapsed'] = 'shown, will collapse, not collapsed',
              },
              func = function()
                check0(f:SetCollapsesLayout(true))
              end,
            },
            setParentFrame = {
              edges = {
                ['shown, will collapse, not collapsed'] = 'invisible, will collapse, collapsed',
                ['shown, will not collapse, not collapsed'] = 'invisible, will not collapse, not collapsed',
              },
              func = function()
                check0(f:SetParent(p))
              end,
            },
            setParentNil = {
              edges = {
                ['invisible, will collapse, collapsed'] = 'shown, will collapse, not collapsed',
                ['invisible, will not collapse, not collapsed'] = 'shown, will not collapse, not collapsed',
              },
              func = function()
                check0(f:SetParent(nil))
              end,
            },
            show = {
              edges = {
                ['hidden, will collapse, collapsed'] = 'shown, will collapse, not collapsed',
                ['hidden, will not collapse, not collapsed'] = 'shown, will not collapse, not collapsed',
              },
              func = function()
                check0(f:Show())
              end,
            },
          }
          return G.checkStateMachine(states, transitions, 'shown, will not collapse, not collapsed')
        end,
        SetAllPoints = function()
          return {
            relativeTo = function()
              local t = {
                explicitregion = function()
                  local r = CreateFrame('Frame')
                  return r, r
                end,
                explicitscreen = function(f)
                  local r = CreateFrame('Frame')
                  f:SetParent(r)
                  return nil, nil
                end,
                implicitparent = function(f)
                  local r = CreateFrame('Frame')
                  f:SetParent(r)
                  return r
                end,
                implicitscreen = function()
                  return nil
                end,
              }
              local function docheck(f, r, ...)
                check0(f:SetAllPoints(...))
                return {
                  num = function()
                    return match(1, 2, f:GetNumPoints())
                  end,
                  pt1 = function()
                    return match(5, 'TOPLEFT', r, 'TOPLEFT', 0, 0, f:GetPoint(1))
                  end,
                  pt2 = function()
                    return match(5, 'BOTTOMRIGHT', r, 'BOTTOMRIGHT', 0, 0, f:GetPoint(2))
                  end,
                }
              end
              local tests = {}
              for k, v in pairs(t) do
                tests[k] = function()
                  local f = CreateFrame('Frame')
                  return docheck(f, v(f))
                end
              end
              return tests
            end,
          }
        end,
        SetPoint = function()
          return {
            badpoint = function()
              local f = CreateFrame('Frame')
              local msg = 'Frame:SetPoint(): Invalid region point nonsense'
              check2(false, msg, pcall(f.SetPoint, f, 'nonsense'))
            end,
            badrelpoint = function()
              local f = CreateFrame('Frame')
              local msg = 'Frame:SetPoint(): Unknown region point nonsense'
              check2(false, msg, pcall(f.SetPoint, f, 'TOPLEFT', nil, 'nonsense'))
            end,
            noarg = function()
              local f = CreateFrame('Frame')
              local msg = table.concat({
                'Frame:SetPoint(): Usage: (',
                '"point" [, region or nil] [, "relativePoint"] [, offsetX, offsetY]',
              })
              check2(false, msg, pcall(f.SetPoint, f))
            end,
          }
        end,
        rect = function()
          if _G.__wowless then -- issue #473
            return
          end
          local f = CreateFrame('Frame')
          local _, _, w, h = _G.WorldFrame:GetRect()
          local states = {
            init = function()
              check1(false, f:IsRectValid())
              check0(f:GetBottom())
              check0(f:GetCenter())
              check1(0, f:GetHeight())
              check1(0, f:GetHeight(true))
              check0(f:GetLeft())
              check1(0, f:GetNumPoints())
              check0(f:GetRect())
              check0(f:GetRight())
              check2(0, 0, f:GetSize())
              check2(0, 0, f:GetSize(true))
              check0(f:GetTop())
              check1(0, f:GetWidth())
              check1(0, f:GetWidth(true))
              check1(false, f:IsRectValid())
            end,
            fiveten = function()
              check1(false, f:IsRectValid())
              check0(f:GetBottom())
              check0(f:GetCenter())
              check1(10, f:GetHeight())
              check0(f:GetLeft())
              check1(0, f:GetNumPoints())
              check0(f:GetRect())
              check0(f:GetRight())
              check2(5, 10, f:GetSize())
              check0(f:GetTop())
              check1(5, f:GetWidth())
              check1(false, f:IsRectValid())
            end,
            screen0 = function()
              check1(false, f:IsRectValid())
            end,
            screen1 = function()
              check1(true, f:IsRectValid())
              check1(0, f:GetBottom())
              check2(w / 2, h / 2, f:GetCenter())
              check1(h, f:GetHeight())
              check1(0, f:GetHeight(true))
              check1(0, f:GetLeft())
              check1(2, f:GetNumPoints())
              check4(0, 0, w, h, f:GetRect())
              check1(w, f:GetRight())
              check2(w, h, f:GetSize())
              check2(0, 0, f:GetSize(true))
              check1(h, f:GetTop())
              check1(w, f:GetWidth())
              check1(0, f:GetWidth(true))
              check1(true, f:IsRectValid())
            end,
            screenfiveten0 = function()
              check1(false, f:IsRectValid())
            end,
            screenfiveten1 = function()
              check1(true, f:IsRectValid())
              check1(0, f:GetBottom())
              check2(w / 2, h / 2, f:GetCenter())
              check1(h, f:GetHeight())
              check1(10, f:GetHeight(true))
              check1(0, f:GetLeft())
              check1(2, f:GetNumPoints())
              check4(0, 0, w, h, f:GetRect())
              check1(w, f:GetRight())
              check2(w, h, f:GetSize())
              check2(5, 10, f:GetSize(true))
              check1(h, f:GetTop())
              check1(w, f:GetWidth())
              check1(5, f:GetWidth(true))
              check1(true, f:IsRectValid())
            end,
          }
          local transitions = {
            getbottom = {
              edges = {
                init = 'init',
                fiveten = 'fiveten',
                screen0 = 'screen1',
                screen1 = 'screen1',
                screenfiveten0 = 'screenfiveten1',
                screenfiveten1 = 'screenfiveten1',
              },
              func = function()
                f:GetBottom()
              end,
            },
            getcenter = {
              edges = {
                init = 'init',
                fiveten = 'fiveten',
                screen0 = 'screen1',
                screen1 = 'screen1',
                screenfiveten0 = 'screenfiveten1',
                screenfiveten1 = 'screenfiveten1',
              },
              func = function()
                f:GetCenter()
              end,
            },
            getheight = {
              edges = {
                init = 'init',
                fiveten = 'fiveten',
                screen0 = 'screen1',
                screen1 = 'screen1',
                screenfiveten0 = 'screenfiveten1',
                screenfiveten1 = 'screenfiveten1',
              },
              func = function()
                f:GetHeight()
              end,
            },
            getheightignorerect = {
              loop = true,
              func = function()
                f:GetHeight(true)
              end,
            },
            getleft = {
              edges = {
                init = 'init',
                fiveten = 'fiveten',
                screen0 = 'screen1',
                screen1 = 'screen1',
                screenfiveten0 = 'screenfiveten1',
                screenfiveten1 = 'screenfiveten1',
              },
              func = function()
                f:GetLeft()
              end,
            },
            getnumpoints = {
              loop = true,
              func = function()
                f:GetNumPoints()
              end,
            },
            getrect = {
              edges = {
                init = 'init',
                fiveten = 'fiveten',
                screen0 = 'screen1',
                screen1 = 'screen1',
                screenfiveten0 = 'screenfiveten1',
                screenfiveten1 = 'screenfiveten1',
              },
              func = function()
                f:GetRect()
              end,
            },
            getright = {
              edges = {
                init = 'init',
                fiveten = 'fiveten',
                screen0 = 'screen1',
                screen1 = 'screen1',
                screenfiveten0 = 'screenfiveten1',
                screenfiveten1 = 'screenfiveten1',
              },
              func = function()
                f:GetRight()
              end,
            },
            getsize = {
              edges = {
                init = 'init',
                fiveten = 'fiveten',
                screen0 = 'screen1',
                screen1 = 'screen1',
                screenfiveten0 = 'screenfiveten1',
                screenfiveten1 = 'screenfiveten1',
              },
              func = function()
                f:GetSize()
              end,
            },
            getsizeignorerect = {
              loop = true,
              func = function()
                f:GetSize(true)
              end,
            },
            gettop = {
              edges = {
                init = 'init',
                fiveten = 'fiveten',
                screen0 = 'screen1',
                screen1 = 'screen1',
                screenfiveten0 = 'screenfiveten1',
                screenfiveten1 = 'screenfiveten1',
              },
              func = function()
                f:GetTop()
              end,
            },
            getwidth = {
              edges = {
                init = 'init',
                fiveten = 'fiveten',
                screen0 = 'screen1',
                screen1 = 'screen1',
                screenfiveten0 = 'screenfiveten1',
                screenfiveten1 = 'screenfiveten1',
              },
              func = function()
                f:GetWidth()
              end,
            },
            getwidthignorerect = {
              loop = true,
              func = function()
                f:GetWidth(true)
              end,
            },
            setallpoints = {
              edges = {
                init = 'screen0',
                fiveten = 'screenfiveten0',
                screen0 = 'screen0',
                screen1 = 'screen0',
                screenfiveten0 = 'screenfiveten0',
                screenfiveten1 = 'screenfiveten0',
              },
              func = function()
                f:SetAllPoints()
              end,
            },
            setsizezerozero = {
              edges = {
                init = 'init',
                fiveten = 'init',
                screen0 = 'screen0',
                screen1 = 'screen1',
                screenfiveten0 = 'screen0',
                screenfiveten1 = 'screen0',
              },
              func = function()
                f:SetSize(0, 0)
              end,
            },
            setsizefiveten = {
              edges = {
                init = 'fiveten',
                fiveten = 'fiveten',
                screen0 = 'screenfiveten0',
                screen1 = 'screenfiveten0',
                screenfiveten0 = 'screenfiveten0',
                screenfiveten1 = 'screenfiveten1',
              },
              func = function()
                f:SetSize(5, 10)
              end,
            },
            reset = {
              to = 'init',
              func = function()
                f:ClearAllPoints()
                f:SetPoint('CENTER')
                f:ClearPoint('CENTER')
                f:SetSize(0, 0)
              end,
            },
          }
          return G.checkStateMachine(states, transitions, 'init')
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
        ['color texture, vertex color, and gradient'] = function()
          local t = CreateFrame('Frame'):CreateTexture()
          local states = {
            init = function()
              check4(1, 1, 1, 1, t:GetVertexColor())
              check1(1, t:GetAlpha())
            end,
            vertex = function()
              check4(0.2, 0.4, 0.6, 0.8, t:GetVertexColor())
              check1(0.8, t:GetAlpha())
            end,
          }
          local transitions = {
            hg = {
              to = 'init',
              func = function()
                local c1 = { r = 1, g = 1, b = 0, a = 1 }
                local c2 = { r = 0, g = 1, b = 1, a = 1 }
                t:SetGradient('HORIZONTAL', c1, c2)
              end,
            },
            vc = {
              to = 'vertex',
              func = function()
                t:SetVertexColor(0.2, 0.4, 0.6, 0.8)
              end,
            },
            vg = {
              to = 'init',
              func = function()
                local c1 = { r = 1, g = 0, b = 0, a = 1 }
                local c2 = { r = 0, g = 1, b = 0, a = 1 }
                t:SetGradient('VERTICAL', c1, c2)
              end,
            },
          }
          return G.checkStateMachine(states, transitions, 'init')
        end,
      }
    end,
    TextureCoordTranslation = function()
      if _G.__wowless then
        return
      end
      -- Cannot be created via Lua CreateAnimation.
      local a = retn(1, CreateFrame('Frame'):CreateAnimationGroup():CreateAnimation('TextureCoordTranslation'))
      return match(1, 'Animation', a:GetObjectType())
    end,
  }
end
