local addonName, G = ...
local assertEquals = _G.assertEquals

local check0 = G.check0
local check1 = G.check1
local check4 = G.check4

local function checkStateMachine(states, transitions, init, x)
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
    return s:sub(select(2, s:find(':%d+: ')) + 1)
  end
  local function checkState(s, n)
    local success, msg = pcall(function()
      states[s](x)
    end)
    if not success then
      error(('%s state: %s'):format(n, trimerr(msg)))
    end
  end
  for from, tos in pairs(edges) do
    for to, ts in pairs(tos) do
      for t in pairs(ts) do
        local success, msg = pcall(function()
          checkState(init, 'init')
          transitions[frominit[from]].func(x)
          checkState(from, 'from')
          transitions[t].func(x)
          checkState(to, 'to')
          transitions[toinit[to]].func(x)
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
      local states = {
        disabled = function(b)
          assertEquals(false, b:IsEnabled())
          assertEquals('DISABLED', b:GetButtonState())
        end,
        normal = function(b)
          assertEquals(true, b:IsEnabled())
          assertEquals('NORMAL', b:GetButtonState())
        end,
        pushed = function(b)
          assertEquals(true, b:IsEnabled())
          assertEquals('PUSHED', b:GetButtonState())
        end,
      }
      local transitions = {
        disable = {
          func = function(b)
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
          func = function(b)
            b:Enable()
          end,
        },
        error = {
          func = function(b)
            assertEquals(
              false,
              pcall(function()
                b:SetButtonState('bad')
              end)
            )
          end,
        },
        setEnabledFalse = {
          to = 'disabled',
          func = function(b)
            b:SetEnabled(false)
          end,
        },
        setEnabledTrue = {
          edges = {
            disabled = 'normal',
            normal = 'normal',
            pushed = 'pushed',
          },
          func = function(b)
            b:SetEnabled(true)
          end,
        },
        setStateDisabled = {
          to = 'disabled',
          func = function(b)
            b:SetButtonState('DISABLED')
          end,
        },
        setStateNormal = {
          to = 'normal',
          func = function(b)
            b:SetButtonState('NORMAL')
          end,
        },
        setStatePushed = {
          to = 'pushed',
          func = function(b)
            b:SetButtonState('PUSHED')
          end,
        },
      }
      return checkStateMachine(states, transitions, 'normal', CreateFrame('Button'))
    end,
    ['button text'] = function()
      local f = CreateFrame('Button')
      assert(f:GetNumRegions() == 0)
      assert(f:GetFontString() == nil)
      f:SetText('Moo')
      assert(f:GetNumRegions() == 1)
      local fs = f:GetFontString()
      assert(fs ~= nil)
      assert(f:GetRegions() == fs)
      assert(fs:GetParent() == f)
      assert(f:GetText() == 'Moo')
      assert(fs:GetText() == 'Moo')
      local g = CreateFrame('Button')
      assert(g:GetText() == nil)
      g:SetFontString(fs)
      assert(g:GetText() == 'Moo')
      assert(g:GetRegions() == fs)
      assert(fs:GetParent() == g)
      assert(f:GetText() == nil)
      assert(f:GetNumRegions() == 0)
      fs:SetParent(f)
      assert(fs:GetParent() == f)
      assert(f:GetNumRegions() == 1)
      assert(f:GetText() == nil)
      assert(f:GetFontString() == nil)
      assert(g:GetNumRegions() == 0)
      assert(g:GetText() == nil)
      assert(g:GetFontString() == nil)
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
          assert(not pcall(function()
            format('%s')
          end))
        end,
        ['does not format nil strings'] = function()
          assert(not pcall(function()
            format('%s', nil)
          end))
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
          assert(not pcall(function()
            format('%100$d', unpack(t))
          end))
        end,
        ['format handles %f'] = function()
          assertEquals('inf', format('%f', math.huge):sub(-3))
          assertEquals('nan', format('%f', -math.sin(math.huge)):sub(-3))
        end,
        ['format handles %F'] = function()
          assertEquals('inf', format('%F', math.huge):sub(-3))
          assertEquals('nan', format('%F', -math.sin(math.huge)):sub(-3))
        end,
      }
    end,
    ['frame'] = function()
      return {
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
      }
    end,

    GameTooltip = function()
      local f = function(n, ...)
        if n ~= select('#', ...) then
          error('wrong number of return values', 2)
        end
        return ...
      end
      return {
        init = function()
          local gt = f(1, CreateFrame('GameTooltip'))
          return {
            GetAnchorType = function()
              assertEquals('ANCHOR_NONE', f(1, gt:GetAnchorType()))
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
        Kids = function()
          if _G.__wowless then
            return
          end
          local parent = f(1, CreateFrame('Frame'))
          local gt = f(1, CreateFrame('GameTooltip'))
          local fs1 = f(1, parent:CreateFontString())
          local fs2 = f(1, parent:CreateFontString())
          f(0, gt:AddFontStrings(fs1, fs2))
          f(0, gt:GetRegions())
          assertEquals(0, f(1, fs1:GetNumPoints()))
          assertEquals(0, f(1, fs2:GetNumPoints()))
          f(0, gt:SetOwner(parent, 'ANCHOR_NONE'))
          f(0, gt:GetRegions())
          assertEquals(0, f(1, fs1:GetNumPoints()))
          assertEquals(0, f(1, fs2:GetNumPoints()))
          f(0, gt:SetText('Hello, world!'))
          f(2, gt:GetRegions())
          assertEquals(2, f(1, fs1:GetNumPoints()))
          local p1point, p1relativeTo, p1relativePoint, p1x, p1y = f(5, fs1:GetPoint(1))
          assertEquals('TOP', p1point)
          assertEquals(gt, p1relativeTo)
          assertEquals('TOP', p1relativePoint)
          assertEquals(0, p1x)
          assertEquals(-10, p1y)
          local p2point, p2relativeTo, p2relativePoint, p2x, p2y = f(5, fs1:GetPoint(2))
          assertEquals('LEFT', p2point)
          assertEquals(gt, p2relativeTo)
          assertEquals('LEFT', p2relativePoint)
          assertEquals(10, p2x)
          assertEquals(0, p2y)
          assertEquals(1, f(1, fs2:GetNumPoints()))
          local p3point, p3relativeTo, p3relativePoint, p3x, p3y = f(5, fs2:GetPoint(1))
          assertEquals('RIGHT', p3point)
          assertEquals(fs1, p3relativeTo)
          assertEquals('LEFT', p3relativePoint)
          assertEquals(40.4, p3x)
          assertEquals(0, p3y)
          f(0, gt:Show())
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
              assertEquals(
                false,
                pcall(function()
                  gt:SetOwner()
                end)
              )
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

    ['ScrollFrame:SetScrollChild'] = function()
      local f = CreateFrame('ScrollFrame')
      assertEquals(nil, f:GetScrollChild())
      local g = CreateFrame('Frame', 'WowlessScrollFrameChild')
      f:SetScrollChild(g)
      assertEquals(g, f:GetScrollChild())
      f:SetScrollChild(nil)
      assertEquals(nil, f:GetScrollChild())
      f:SetScrollChild('WowlessScrollFrameChild')
      assertEquals(g, f:GetScrollChild())
      assertEquals(
        false,
        pcall(function()
          f:SetScrollChild()
        end)
      )
    end,
    ['status bar'] = function()
      local sb = CreateFrame('StatusBar')
      check1(nil, sb:GetStatusBarTexture())
      check4(1, 1, 1, 1, sb:GetStatusBarColor())
      check1(nil, sb:GetStatusBarTexture())
      check0(sb:SetStatusBarColor(0, 1, 0, 1))
      check4(1, 1, 1, 1, sb:GetStatusBarColor())
      sb:SetStatusBarTexture('interface/icons/temp')
      local t = sb:GetStatusBarTexture()
      assert(t ~= nil)
      check4(1, 1, 1, 1, sb:GetStatusBarColor())
      check4(1, 1, 1, 1, t:GetVertexColor())
      check0(t:SetVertexColor(0.8, 0.6, 0.4, 0.2))
      check4(0.8, 0.6, 0.4, 0.2, sb:GetStatusBarColor())
      check4(0.8, 0.6, 0.4, 0.2, t:GetVertexColor())
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
    ['version'] = function()
      local id = _G.WOW_PROJECT_ID
      if id == 1 then
        assertEquals(id, _G.WOW_PROJECT_MAINLINE)
      elseif id == 2 then
        assertEquals(id, _G.WOW_PROJECT_CLASSIC)
      elseif id == 5 then
        assertEquals(id, _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
      else
        error('invalid WOW_PROJECT_ID')
      end
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
