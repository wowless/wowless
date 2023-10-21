local addonName, G, extraArg = ...
local assertEquals = _G.assertEquals

local check0 = G.check0
local check1 = G.check1
local check4 = G.check4

local function checkStateMachine(states, transitions, init)
  local edges = {}
  for s in pairs(states) do
    edges[s] = {}
    for ss in pairs(states) do
      edges[s][ss] = {}
    end
  end
  for k, v in pairs(transitions) do
    if v.edges then
      for from, to in pairs(v.edges) do
        edges[from][to][k] = true
      end
    else
      for s in pairs(states) do
        edges[s][v.to or s][k] = true
      end
    end
  end
  local frominit = {}
  for k in pairs(edges) do
    local t = next(edges[init][k])
    assert(t, 'no way to ' .. k .. ' from ' .. init) -- TODO generalize
    frominit[k] = t
  end
  local toinit = {}
  for k, v in pairs(edges) do
    local t = next(v[init])
    assert(t, 'no way back to ' .. init .. ' from ' .. k) -- TODO generalize
    toinit[k] = t
  end
  local function trimerr(s)
    local _, n = s:find(':%d+: ')
    return n and s:sub(n + 1) or s
  end
  local function checkState(s, n)
    local success, msg = pcall(states[s])
    if not success then
      error(('%s state: %s'):format(n, trimerr(msg)))
    end
  end
  local function checkTransition(t, n)
    local success, msg = pcall(transitions[t].func)
    if not success then
      error(('%s transition: %s'):format(n, trimerr(msg)))
    end
  end
  for from, tos in pairs(edges) do
    for to, ts in pairs(tos) do
      for t in pairs(ts) do
        local success, msg = pcall(function()
          checkState(init, 'init')
          checkTransition(frominit[from], 'init -> from')
          checkState(from, 'from')
          checkTransition(t, 'from -> to')
          checkState(to, 'to')
          checkTransition(toinit[to], 'to -> init')
          checkState(init, 'postinit(' .. toinit[to] .. ')')
        end)
        if not success then
          error(('failure on %s -> %s transition %s: %s'):format(from, to, t, trimerr(msg)))
        end
      end
    end
  end
end

local syncTests = function()
  return {
    ['button states'] = function()
      local b = CreateFrame('Button')
      local states = {
        disabled = function()
          assertEquals(false, b:IsEnabled())
          assertEquals('DISABLED', b:GetButtonState())
        end,
        normal = function()
          assertEquals(true, b:IsEnabled())
          assertEquals('NORMAL', b:GetButtonState())
        end,
        pushed = function()
          assertEquals(true, b:IsEnabled())
          assertEquals('PUSHED', b:GetButtonState())
        end,
      }
      local transitions = {
        disable = {
          func = function()
            b:Disable()
          end,
          to = 'disabled',
        },
        enable = {
          edges = {
            disabled = 'normal',
            normal = 'normal',
            pushed = 'pushed',
          },
          func = function()
            b:Enable()
          end,
        },
        error = {
          func = function()
            assertEquals(false, pcall(b.SetButtonState, b, 'bad'))
          end,
        },
        setEnabledFalse = {
          to = 'disabled',
          func = function()
            b:SetEnabled(false)
          end,
        },
        setEnabledTrue = {
          edges = {
            disabled = 'normal',
            normal = 'normal',
            pushed = 'pushed',
          },
          func = function()
            b:SetEnabled(true)
          end,
        },
        setStateDisabled = {
          to = 'disabled',
          func = function()
            b:SetButtonState('DISABLED')
          end,
        },
        setStateNormal = {
          to = 'normal',
          func = function()
            b:SetButtonState('NORMAL')
          end,
        },
        setStatePushed = {
          to = 'pushed',
          func = function()
            b:SetButtonState('PUSHED')
          end,
        },
      }
      return checkStateMachine(states, transitions, 'normal')
    end,

    ['button text'] = function()
      local f = CreateFrame('Button')
      local g = CreateFrame('Button')
      local garbage = CreateFrame('Frame')
      local function checkEmpty(b)
        check1(0, b:GetNumRegions())
        check1(nil, b:GetFontString())
        check1(nil, b:GetText())
      end
      local function checkNotEmpty(b)
        local fs = assert(b:GetFontString())
        check1(1, b:GetNumRegions())
        assertEquals(fs, (b:GetRegions()))
        assertEquals(b, fs:GetParent())
        check1('Moo', b:GetText())
        check1('Moo', fs:GetText())
      end
      local states = {
        both = function()
          checkNotEmpty(f)
          checkNotEmpty(g)
        end,
        fstr = function()
          check1(1, f:GetNumRegions())
          check1('FontString', f:GetRegions():GetObjectType())
          check1(nil, f:GetFontString())
          check1(nil, f:GetText())
          checkEmpty(g)
        end,
        ftext = function()
          checkNotEmpty(f)
          checkEmpty(g)
        end,
        gtext = function()
          checkEmpty(f)
          checkNotEmpty(g)
        end,
        reset = function()
          checkEmpty(f)
          checkEmpty(g)
        end,
      }
      local transitions = {
        Hack = { -- TODO remove when we can walk from init
          edges = { reset = 'both' },
          func = function()
            check0(f:SetText('Moo'))
            check0(g:SetText('Moo'))
          end,
        },
        Hack2 = {
          edges = { reset = 'fstr' },
          func = function()
            f:CreateFontString()
          end,
        },
        Reset = {
          to = 'reset',
          func = function()
            local function trash(...)
              for i = 1, select('#', ...) do
                select(i, ...):SetParent(garbage)
              end
            end
            trash(f:GetRegions())
            trash(g:GetRegions())
          end,
        },
        SetFontStringFtoG = {
          edges = {
            ftext = 'gtext',
          },
          func = function()
            check0(g:SetFontString(f:GetFontString()))
          end,
        },
        SetParentGtoF = {
          edges = {
            gtext = 'fstr',
          },
          func = function()
            check0(g:GetFontString():SetParent(f))
          end,
        },
        SetTextF = {
          edges = {
            both = 'both',
            ftext = 'ftext',
            gtext = 'both',
            reset = 'ftext',
          },
          func = function()
            check0(f:SetText('Moo'))
          end,
        },
        SetTextG = {
          edges = {
            both = 'both',
            ftext = 'both',
            gtext = 'gtext',
            reset = 'gtext',
          },
          func = function()
            check0(g:SetText('Moo'))
          end,
        },
      }
      return checkStateMachine(states, transitions, 'reset')
    end,

    ['button textures'] = function()
      return {
        ['parent'] = function()
          local function init()
            local b = CreateFrame('Button')
            local t = b:CreateTexture()
            b:SetNormalTexture(t)
            return b, t, CreateFrame('Frame')
          end
          return {
            ['multiple sets have no effect'] = function()
              local b, t = init()
              b:SetNormalTexture(t)
              assertEquals(1, b:GetNumRegions())
              b:SetPushedTexture(t)
              assertEquals(1, b:GetNumRegions())
              assertEquals(t, b:GetNormalTexture())
              assertEquals(t, b:GetPushedTexture())
            end,
            ['reparent clears'] = function()
              local b, t, f = init()
              t:SetParent(f)
              assertEquals(0, b:GetNumRegions())
              assertEquals(nil, b:GetNormalTexture())
            end,
            ['reset sets parent'] = function()
              local b, t, f = init()
              t:SetParent(f)
              b:SetNormalTexture(t)
              assertEquals(b, t:GetParent())
            end,
            ['reuse texture with name'] = function()
              local b, t = init()
              b:SetNormalTexture(136235)
              assertEquals(1, b:GetNumRegions())
              assertEquals(136235, t:GetTexture())
            end,
            ['round trip clears'] = function()
              local b, t, f = init()
              t:SetParent(f)
              t:SetParent(b)
              assertEquals(1, b:GetNumRegions())
              assertEquals(nil, b:GetNormalTexture())
            end,
            ['second texture coexists with first'] = function()
              local b, t = init()
              local t2 = b:CreateTexture()
              b:SetNormalTexture(t2)
              assertEquals(2, b:GetNumRegions())
              assertEquals(t2, b:GetNormalTexture())
              assertEquals(b, t:GetParent())
            end,
          }
        end,
        ['states'] = function()
          local b = CreateFrame('Button')
          assertEquals(nil, b:GetDisabledTexture())
          assertEquals(nil, b:GetHighlightTexture())
          assertEquals(nil, b:GetNormalTexture())
          assertEquals(nil, b:GetPushedTexture())
          local dt = b:CreateTexture()
          assertEquals(0, dt:GetNumPoints())
          dt:Show()
          b:SetDisabledTexture(dt)
          assertEquals(dt, b:GetDisabledTexture())
          assertEquals(false, dt:IsShown())
          assertEquals(2, dt:GetNumPoints())
          local nt = b:CreateTexture()
          assertEquals(0, nt:GetNumPoints())
          nt:Hide()
          b:SetNormalTexture(nt)
          assertEquals(nt, b:GetNormalTexture())
          assertEquals(true, nt:IsShown())
          assertEquals(2, nt:GetNumPoints())
          local pt = b:CreateTexture()
          assertEquals(0, pt:GetNumPoints())
          pt:Show()
          b:SetPushedTexture(pt)
          assertEquals(pt, b:GetPushedTexture())
          assertEquals(false, pt:IsShown())
          assertEquals(2, pt:GetNumPoints())
          local ht = b:CreateTexture()
          assertEquals(0, ht:GetNumPoints())
          ht:Hide()
          assertEquals('ARTWORK', ht:GetDrawLayer())
          b:SetHighlightTexture(ht)
          assertEquals(ht, b:GetHighlightTexture())
          assertEquals(true, ht:IsShown())
          assertEquals('HIGHLIGHT', ht:GetDrawLayer())
          assertEquals(2, ht:GetNumPoints())
          assertEquals(4, b:GetNumRegions())
          local r1, r2, r3, r4 = b:GetRegions()
          assertEquals(dt, r1)
          assertEquals(nt, r2)
          assertEquals(pt, r3)
          assertEquals(ht, r4)
          b:Disable()
          assertEquals(true, dt:IsShown())
          assertEquals(false, nt:IsShown())
          assertEquals(false, pt:IsShown())
          assertEquals(true, ht:IsShown())
          b:SetButtonState('PUSHED')
          assertEquals(false, dt:IsShown())
          assertEquals(false, nt:IsShown())
          assertEquals(true, pt:IsShown())
          assertEquals(true, ht:IsShown())
        end,
      }
    end,
    ['coroutine'] = function()
      local log = {}
      local co = coroutine.create(function()
        table.insert(log, 'b')
        coroutine.yield()
        table.insert(log, 'e')
      end)
      table.insert(log, 'a')
      assert(coroutine.resume(co))
      table.insert(log, 'c')
      assertEquals('suspended', coroutine.status(co))
      table.insert(log, 'd')
      assert(coroutine.resume(co))
      table.insert(log, 'f')
      assertEquals('dead', coroutine.status(co))
      assertEquals('a,b,c,d,e,f', table.concat(log, ','))
    end,
    ['format'] = function()
      return {
        ['format missing numbers'] = function()
          assertEquals('0', format('%d'))
        end,
        ['format nil numbers'] = function()
          assertEquals('0', format('%d', nil))
        end,
        ['does not format missing strings'] = function()
          assert(not pcall(format, '%s'))
        end,
        ['does not format nil strings'] = function()
          assert(not pcall(format, '%s', nil))
        end,
        ['format handles indexed substitution'] = function()
          assertEquals(' 7   moo', format('%2$2d %1$5s', 'moo', 7))
        end,
        ['format handles up to index 99 substitution'] = function()
          local t = {}
          for i = 1, 100 do
            t[i] = i
          end
          for i = 1, 99 do
            assertEquals(tostring(i), format('%' .. i .. '$d', unpack(t)))
          end
          assert(not pcall(format, '%100$d', unpack(t)))
        end,
        ['format handles %f'] = function()
          assertEquals('inf', format('%f', math.huge):sub(-3))
        end,
        ['format handles %F'] = function()
          assertEquals('inf', format('%F', math.huge):sub(-3))
        end,
      }
    end,
    ['frame'] = function()
      return {
        ['creation with frame in name position'] = function()
          local f = CreateFrame('Frame')
          local g = CreateFrame('Frame', f)
          assert(g:GetName() == nil)
          assert(g:GetParent() == nil)
        end,
        ['creation with number name'] = function()
          assertEquals('999', CreateFrame('Frame', 999):GetName())
        end,
        ['kid order'] = function()
          return {
            ['three'] = function()
              local f = CreateFrame('Frame')
              local g = CreateFrame('Frame', nil, f)
              local h = CreateFrame('Frame', nil, f)
              local i = CreateFrame('Frame', nil, f)
              assert(f:GetNumChildren() == 3)
              assert(select(1, f:GetChildren()) == g)
              assert(select(2, f:GetChildren()) == h)
              assert(select(3, f:GetChildren()) == i)
              h:SetParent(nil)
              assert(f:GetNumChildren() == 2)
              assert(select(1, f:GetChildren()) == g)
              assert(select(2, f:GetChildren()) == i)
              h:SetParent(f)
              assert(f:GetNumChildren() == 3)
              assert(select(1, f:GetChildren()) == g)
              assert(select(2, f:GetChildren()) == i)
              assert(select(3, f:GetChildren()) == h)
            end,
            ['two'] = function()
              local f = CreateFrame('Frame')
              local g = CreateFrame('Frame')
              local h = CreateFrame('Frame')
              g:SetParent(f)
              h:SetParent(f)
              assert(f:GetNumChildren() == 2)
              assert(select(1, f:GetChildren()) == g)
              assert(select(2, f:GetChildren()) == h)
              g:SetParent(f)
              assert(select(1, f:GetChildren()) == g)
              assert(select(2, f:GetChildren()) == h)
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
        ['parent keys'] = function()
          local up = CreateFrame('Frame')
          local down = CreateFrame('Frame', nil, up)
          check1(nil, down:GetParentKey())
          up.moo = down
          check1('moo', down:GetParentKey())
          check0(down:SetParentKey('cow'))
          assertEquals(up.cow, down)
          if up.ClearParentKey then
            assertEquals(nil, up.moo)
          else
            assertEquals(up.moo, down)
            check1('moo', down:GetParentKey())
            up.moo = nil
          end
          check1('cow', down:GetParentKey())
          up.cow = nil
          check1(nil, down:GetParentKey())
        end,
      }
    end,

    GameTooltip = function()
      local f = function(n, ...)
        local k = select('#', ...)
        if n ~= k then
          error(string.format('wrong number of return values: want %d, got %d', n, k), 2)
        end
        return ...
      end
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

    loading = function()
      return {
        addonName = function()
          assertEquals('Wowless', addonName)
        end,
        addonTable = function()
          assertEquals('table', type(G))
          assertEquals(nil, getmetatable(G))
        end,
        extraArg = function()
          assertEquals(nil, extraArg)
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

    secureexecuterange = function()
      return {
        empty = function()
          check0(secureexecuterange({}, error))
        end,
        nonempty = function()
          local log = {}
          check0(secureexecuterange({ 'foo', 'bar' }, function(...)
            table.insert(log, '[')
            for i = 1, select('#', ...) do
              table.insert(log, (select(i, ...)))
            end
            table.insert(log, ']')
          end, 'baz', 'quux'))
          assertEquals('[,1,foo,baz,quux,],[,2,bar,baz,quux,]', table.concat(log, ','))
        end,
      }
    end,

    StatusBar = function()
      local sb = CreateFrame('StatusBar')
      local nilparent = CreateFrame('Frame')
      local states = {
        colorTexture = function()
          local t = assert(sb:GetStatusBarTexture())
          check4(0.8, 0.6, 0.4, 0.2, t:GetVertexColor())
          check4(0.8, 0.6, 0.4, 0.2, sb:GetStatusBarColor())
        end,
        empty = function()
          check1(nil, sb:GetStatusBarTexture())
          check4(1, 1, 1, 1, sb:GetStatusBarColor())
        end,
        resetTexture = function()
          local t = assert(sb:GetStatusBarTexture())
          check4(1, 1, 1, 1, t:GetVertexColor())
          check4(1, 1, 1, 1, sb:GetStatusBarColor())
        end,
      }
      local transitions = {
        Hack = { -- TODO remove when we can walk from init
          to = 'colorTexture',
          func = function()
            check0(sb:SetStatusBarTexture('interface/icons/temp'))
            check0(sb:SetStatusBarColor(0.8, 0.6, 0.4, 0.2))
          end,
        },
        SetStatusBarColor = {
          edges = {
            colorTexture = 'colorTexture',
            empty = 'empty',
            resetTexture = 'colorTexture',
          },
          func = function()
            check0(sb:SetStatusBarColor(0.8, 0.6, 0.4, 0.2))
          end,
        },
        SetStatusBarTexture = {
          edges = {
            colorTexture = 'colorTexture',
            empty = 'resetTexture',
            resetTexture = 'resetTexture',
          },
          func = function()
            check0(sb:SetStatusBarTexture('interface/icons/temp'))
          end,
        },
        SetStatusBarTextureNil = {
          to = 'empty',
          func = function()
            local t = sb:GetStatusBarTexture()
            if t then
              t:SetParent(nilparent)
            end
          end,
        },
      }
      return checkStateMachine(states, transitions, 'empty')
    end,

    ['table'] = function()
      return {
        wipe = function()
          local t = { 1, 2, 3 }
          local w = table.wipe(t)
          assertEquals(w, t)
          assertEquals(nil, next(t))
        end,
      }
    end,
    ['texture'] = function()
      local t = CreateFrame('Frame'):CreateTexture()
      assertEquals('BLEND', t:GetBlendMode())
      t:SetColorTexture(0.8, 0.6, 0.4, 0.2)
      assertEquals(IsTestBuild() and 'FileData ID 0' or nil, t:GetTexture())
      check4(1, 1, 1, 1, t:GetVertexColor())
      t:SetTexture(136235)
      assertEquals(136235, t:GetTexture())
      t:SetColorTexture(0.8, 0.6, 0.4, 0.2)
      assertEquals(IsTestBuild() and 'FileData ID 0' or nil, t:GetTexture())
    end,
    ['visible updated on kids before calling any OnShow'] = function()
      local p = CreateFrame('Frame')
      local k1 = CreateFrame('Frame', nil, p)
      local k2 = CreateFrame('Frame', nil, p)
      local log = {}
      local function h(name)
        return function()
          table.insert(
            log,
            table.concat({
              name,
              tostring(p:IsShown()),
              tostring(p:IsVisible()),
              tostring(k1:IsShown()),
              tostring(k1:IsVisible()),
              tostring(k2:IsShown()),
              tostring(k2:IsVisible()),
            }, ',')
          )
        end
      end
      p:SetScript('OnShow', h('parent'))
      k1:SetScript('OnShow', h('kid 1'))
      k2:SetScript('OnShow', h('kid 2'))
      p:Hide()
      p:Show()
      local expected = table.concat({
        'kid 1' .. (',true'):rep(6),
        'kid 2' .. (',true'):rep(6),
        'parent' .. (',true'):rep(6),
      }, '\n')
      assertEquals(expected, table.concat(log, '\n'))
    end,
    ['visible updated on kids before OnShow across three parent-kids'] = function()
      local p = CreateFrame('Frame')
      local m = CreateFrame('Frame', nil, p)
      local k = CreateFrame('Frame', nil, m)
      local log = {}
      local function h(name)
        return function()
          table.insert(
            log,
            table.concat({
              name,
              tostring(p:IsShown()),
              tostring(p:IsVisible()),
              tostring(m:IsShown()),
              tostring(m:IsVisible()),
              tostring(k:IsShown()),
              tostring(k:IsVisible()),
            }, ',')
          )
        end
      end
      p:SetScript('OnShow', h('parent'))
      m:SetScript('OnShow', h('middle'))
      k:SetScript('OnShow', h('kid'))
      p:Hide()
      p:Show()
      local expected = table.concat({
        'kid' .. (',true'):rep(6),
        'middle' .. (',true'):rep(6),
        'parent' .. (',true'):rep(6),
      }, '\n')
      assertEquals(expected, table.concat(log, '\n'))
    end,
    WorldFrame = function()
      return {
        ['is a normal frame'] = function()
          if _G.WorldFrame then
            assertEquals('Frame', _G.WorldFrame:GetObjectType())
          end
        end,
        ['is not a frame type'] = function()
          assertEquals(false, (pcall(CreateFrame, 'WorldFrame')))
          table.insert(_G.Wowless.ExpectedLuaWarnings, {
            warnText = 'Unknown frame type: WorldFrame',
            warnType = 0,
          })
        end,
      }
    end,
  }
end

local asyncTests = {
  {
    name = 'event registration and dispatch order',
    fn = function(done)
      local event = 'CHAT_MSG_SYSTEM'
      local msg = 'event registration and dispatch order'
      local log = {}
      local pending = 0
      local function mkframe(name)
        local f = CreateFrame('Frame')
        pending = pending + 1
        local logged = false
        f:SetScript('OnEvent', function(_, ev, m)
          if not logged and ev == event and m == msg then
            table.insert(log, name)
            logged = true
            pending = pending - 1
            f:UnregisterAllEvents()
            if pending == 0 then
              done(function()
                local t1 = 't32,t2,t24,t4,t30,t6,t18,t8,t28,t10,t22,t12,t26,t14,t20,t16'
                local t2 = 't1,t5,t9,t13,t17,t21,t25,t29,t3,t7,t11,t15,t19,t23,t27,t31'
                local a1 = 'a32,a2,a24,a4,a30,a6,a18,a8,a28,a10,a22,a12,a26,a14,a20,a16'
                local a2 = 'a1,a5,a9,a13,a17,a21,a25,a29,a3,a7,a11,a15,a19,a23,a27,a31'
                assertEquals(table.concat({ t1, t2, a1, a2 }, ','), table.concat(log, ','))
              end)
            end
          end
        end)
        return f
      end
      local t, a = {}, {}
      for i = 1, 32 do
        table.insert(a, mkframe('a' .. i))
        table.insert(t, mkframe('t' .. i))
      end
      for _, f in ipairs(t) do
        f:RegisterEvent(event)
      end
      for _, f in ipairs(a) do
        f:RegisterAllEvents()
      end
      for i = 1, 32, 2 do
        t[i]:UnregisterEvent(event)
        a[i]:UnregisterAllEvents()
      end
      for i = 1, 32, 4 do
        t[i]:RegisterEvent(event)
        a[i]:RegisterAllEvents()
      end
      for i = 3, 32, 4 do
        t[i]:RegisterEvent(event)
        a[i]:RegisterAllEvents()
      end
      assertEquals(0, #log)
      SendSystemMessage(msg)
    end,
  },
  {
    name = 'individual event reg before all',
    fn = function(done)
      local event = 'CHAT_MSG_SYSTEM'
      local msg = 'individual event reg before all'
      local log = {}
      local pending = 0
      local function mkframe(name)
        local f = CreateFrame('Frame')
        pending = pending + 1
        local logged = false
        f:SetScript('OnEvent', function(_, ev, m)
          if not logged and ev == event and m == msg then
            table.insert(log, name)
            logged = true
            pending = pending - 1
            f:UnregisterAllEvents()
            if pending == 0 then
              done(function()
                assertEquals('t1,t2,a1,a2', table.concat(log, ','))
              end)
            end
          end
        end)
        return f
      end
      mkframe('t1'):RegisterEvent(event)
      mkframe('a1'):RegisterAllEvents()
      mkframe('a2'):RegisterAllEvents()
      mkframe('t2'):RegisterEvent(event)
      SendSystemMessage(msg)
    end,
  },
  {
    name = 'RequestTimePlayed',
    fn = function(done)
      local frame = CreateFrame('Frame')
      frame:RegisterEvent('TIME_PLAYED_MSG')
      frame:SetScript('OnEvent', function(_, _, total, level, ...)
        local nextra = select('#', ...)
        done(function()
          assertEquals(0, nextra)
          assertEquals('number', type(total))
          assertEquals('number', type(level))
          assert(total >= level)
        end)
      end)
      RequestTimePlayed()
    end,
  },
}

_G.WowlessTestFailures = {}
_G.WowlessTestsDone = false
do
  local syncIter, syncState = G.tests(function()
    return {
      api = G.ApiTests,
      generated = G.GeneratedTests,
      sync = syncTests,
    }
  end)
  local numSyncTests, asyncIndex, numAsyncTests, asyncPending = 0, 0, #asyncTests, false
  local totalTime, numFrames = 0, 0
  local variablesLoaded = false
  do
    local f = CreateFrame('Frame')
    f:SetScript('OnEvent', function()
      variablesLoaded = true
    end)
    f:RegisterEvent('VARIABLES_LOADED')
  end
  CreateFrame('Frame'):SetScript('OnUpdate', function(frame, elapsed)
    if not variablesLoaded then
      return
    end
    totalTime = totalTime + elapsed
    numFrames = numFrames + 1
    local ts = debugprofilestop()
    local budgetMillis = elapsed * 1000 / 2
    for scope, err in syncIter, syncState do
      numSyncTests = numSyncTests + 1
      if err then
        local t = _G.WowlessTestFailures
        for i = 1, #scope - 1 do
          local k = scope[i]
          t[k] = t[k] or {}
          t = t[k]
        end
        t[scope[#scope]] = err
      end
      if numSyncTests % 100 == 0 and debugprofilestop() - ts >= budgetMillis then
        return
      end
    end
    if not asyncPending then
      if asyncIndex == numAsyncTests then
        frame:SetScript('OnUpdate', nil)
        if _G.WowlessData.Build.flavor ~= 'Mainline' then -- TODO reenable for mainline
          _G.WowlessTestFailures.LUA_WARNING = (function()
            local function check()
              assertEquals(#G.ExpectedLuaWarnings, #G.ActualLuaWarnings)
              for i, e in ipairs(G.ExpectedLuaWarnings) do
                local a = G.ActualLuaWarnings[i]
                assertEquals(e.warnType, a.warnType)
                assertEquals(e.warnText, a.warnText)
              end
            end
            if not pcall(check) then
              return {
                actual = G.ActualLuaWarnings,
                expected = G.ExpectedLuaWarnings,
              }
            end
          end)()
        end
        _G.WowlessTestsDone = true
        local print = DevTools_Dump and print or function() end
        print(('Wowless testing completed in %.1fs (%d frames).'):format(totalTime, numFrames))
        print(('Ran %d sync and %d async tests.'):format(numSyncTests, numAsyncTests))
        if not next(_G.WowlessTestFailures) then
          print('No errors.')
        else
          print('There were errors.')
          local dump = _G.__wowless and _G.__wowless.dump or DevTools_Dump
          dump(_G.WowlessTestFailures)
        end
        if _G.UIParent then
          _G.UIParent:RegisterEvent('LUA_WARNING')
        end
        G.LuaWarningsFrame:UnregisterAllEvents()
      else
        asyncIndex = asyncIndex + 1
        asyncPending = true
        local test = asyncTests[asyncIndex]
        test.fn(function(check)
          asyncPending = false
          local success, msg = pcall(check)
          if not success then
            _G.WowlessTestFailures.async = _G.WowlessTestFailures.async or {}
            _G.WowlessTestFailures.async[test.name] = msg
          end
        end)
      end
    end
  end)
end

do
  local saver = CreateFrame('Frame')
  saver:RegisterEvent('ADDON_LOADED')
  saver:SetScript('OnEvent', function(_, _, name)
    if name == addonName then
      _G.WowlessLastTestFailures = _G.WowlessTestFailures
    end
  end)
end
