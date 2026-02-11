local addonName, G, extraArg = ...
local numAddonArgs = select('#', ...)
local assertEquals = _G.assertEquals

local check0 = G.check0
local check1 = G.check1
local check2 = G.check2
local check4 = G.check4
local checkStateMachine = G.checkStateMachine

G.testsuite.sync = function()
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
          loop = true,
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

    ['event registration'] = function()
      local f = CreateFrame('Frame')
      local states = {
        both = function()
          check2(true, nil, f:IsEventRegistered('PLAYER_LOGIN'))
          check2(true, nil, f:IsEventRegistered('PLAYER_ENTERING_WORLD'))
          check2(false, nil, f:IsEventRegistered('PLAYER_LOGOUT'))
        end,
        justlogin = function()
          check2(true, nil, f:IsEventRegistered('PLAYER_LOGIN'))
          check2(false, nil, f:IsEventRegistered('PLAYER_ENTERING_WORLD'))
          check2(false, nil, f:IsEventRegistered('PLAYER_LOGOUT'))
        end,
        justpew = function()
          check2(false, nil, f:IsEventRegistered('PLAYER_LOGIN'))
          check2(true, nil, f:IsEventRegistered('PLAYER_ENTERING_WORLD'))
          check2(false, nil, f:IsEventRegistered('PLAYER_LOGOUT'))
        end,
        none = function()
          check2(false, nil, f:IsEventRegistered('PLAYER_LOGIN'))
          check2(false, nil, f:IsEventRegistered('PLAYER_ENTERING_WORLD'))
          check2(false, nil, f:IsEventRegistered('PLAYER_LOGOUT'))
        end,
      }
      local transitions = {
        registerall = {
          func = function()
            check0(f:RegisterAllEvents())
          end,
          loop = true,
        },
        registergarbage = {
          func = function()
            assert(not pcall(function()
              f:RegisterEvent('WOWLESS_NOPE')
            end))
          end,
          loop = true,
        },
        registerloginfailure = {
          edges = {
            both = 'both',
            justlogin = 'justlogin',
          },
          func = function()
            check1(false, f:RegisterEvent('PLAYER_LOGIN'))
          end,
        },
        registerloginsuccess = {
          edges = {
            justpew = 'both',
            none = 'justlogin',
          },
          func = function()
            check1(true, f:RegisterEvent('PLAYER_LOGIN'))
          end,
        },
        registerpewfailure = {
          edges = {
            both = 'both',
            justpew = 'justpew',
          },
          func = function()
            check1(false, f:RegisterEvent('PLAYER_ENTERING_WORLD'))
          end,
        },
        registerpewsuccess = {
          edges = {
            justlogin = 'both',
            none = 'justpew',
          },
          func = function()
            check1(true, f:RegisterEvent('PLAYER_ENTERING_WORLD'))
          end,
        },
        unregisterall = {
          func = function()
            check0(f:UnregisterAllEvents())
          end,
          to = 'none',
        },
        unregistergarbage = {
          func = function()
            assert(not pcall(function()
              f:UnregisterEvent('WOWLESS_NOPE')
            end))
          end,
          loop = true,
        },
        unregisterloginfailure = {
          edges = {
            justpew = 'justpew',
            none = 'none',
          },
          func = function()
            check1(false, f:UnregisterEvent('PLAYER_LOGIN'))
          end,
        },
        unregisterloginsuccess = {
          edges = {
            both = 'justpew',
            justlogin = 'none',
          },
          func = function()
            check1(true, f:UnregisterEvent('PLAYER_LOGIN'))
          end,
        },
        unregisterpewfailure = {
          edges = {
            justlogin = 'justlogin',
            none = 'none',
          },
          func = function()
            check1(false, f:UnregisterEvent('PLAYER_ENTERING_WORLD'))
          end,
        },
        unregisterpewsuccess = {
          edges = {
            both = 'justlogin',
            justpew = 'none',
          },
          func = function()
            check1(true, f:UnregisterEvent('PLAYER_ENTERING_WORLD'))
          end,
        },
      }
      return checkStateMachine(states, transitions, 'none')
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
        numAddonArgs = function()
          assertEquals(2, numAddonArgs)
        end,
      }
    end,

    StatusBar = function()
      local sb = CreateFrame('StatusBar')
      local nilparent = CreateFrame('Frame')
      local function checkSetStatusBarTexture()
        check1(true, sb:SetStatusBarTexture('interface/icons/temp'))
      end
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
            checkSetStatusBarTexture()
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

    ScrollingMessageFrame = function()
      if _G.__wowless and _G.__wowless.lite then
        return
      end
      return {
        mixin = function()
          local m = _G.ScrollingMessageFrameSecureMixin or _G.ScrollingMessageFrameMixin
          return {
            empty = function()
              check1(nil, next(m))
            end,
            fn = function()
              -- The function is uninteresting when invoked this way.
              local fn = m.SetOnTextCopiedCallback
              assertEquals('function', type(fn))
              return {
                isluafunc = function()
                  assertEquals(true, (pcall(coroutine.create, fn)))
                end,
                nowrapping = function()
                  local f = CreateFrame('ScrollingMessageFrame')
                  local arg = function() end
                  fn(f, arg)
                  assertEquals(arg, f.onTextCopiedCallback)
                end,
              }
            end,
            metatable = function()
              return {
                call = function()
                  assertEquals(false, (pcall(m)))
                end,
                index = function()
                  assertEquals(nil, m.wowless)
                  m.wowless = 'moo'
                  assertEquals('moo', m.wowless)
                  check2('wowless', 'moo', next(m))
                  assertEquals(nil, CreateFrame('ScrollingMessageFrame').wowless)
                  m.wowless = nil
                  assertEquals(nil, m.wowless)
                  check1(nil, next(m))
                end,
                overwrite = function()
                  local called
                  local function cb()
                    called = true
                  end
                  m.SetOnTextCopiedCallback = cb
                  assertEquals(cb, m.SetOnTextCopiedCallback)
                  check2('SetOnTextCopiedCallback', cb, next(m))
                  CreateFrame('ScrollingMessageFrame'):SetOnTextCopiedCallback(function() end)
                  assertEquals(nil, called)
                  m.SetOnTextCopiedCallback = nil
                  check1(nil, next(m))
                end,
                type = function()
                  assertEquals('number', type(getmetatable(m)))
                end,
              }
            end,
            type = function()
              assertEquals('table', type(m))
            end,
          }
        end,
        fn = function()
          local f = CreateFrame('ScrollingMessageFrame')
          local fn = f.SetOnTextCopiedCallback
          assertEquals('function', type(fn))
          return {
            notluafunc = function()
              assertEquals(false, (pcall(coroutine.create, fn)))
            end,
            wrapsarg = function()
              local called
              local arg = function()
                called = true
              end
              fn(f, arg)
              local cb = f.onTextCopiedCallback
              assertEquals('function', type(cb))
              return {
                notluafunc = function()
                  assertEquals(false, (pcall(coroutine.create, cb)))
                end,
                notsame = function()
                  assertEquals(false, cb == arg)
                end,
                set = function()
                  assertEquals(false, cb == nil)
                end,
                wrapped = function()
                  called = false
                  cb()
                  assertEquals(true, called)
                end,
              }
            end,
          }
        end,
      }
    end,

    SimpleCheckout = function()
      if _G.__wowless then -- scope to lite, issue #405
        return
      end
      local forbidden = _G.SimpleCheckout
      assertEquals(true, forbidden:IsForbidden())
      local normal = CreateFrame('Checkout')
      return {
        metatable = function()
          assertEquals('Forbidden', getmetatable(forbidden))
        end,
        methods = function()
          local t = {}
          for k, v in pairs(getmetatable(normal).__index) do
            t[k] = function()
              assertEquals(false, forbidden[k] == nil)
              assertEquals(false, forbidden[k] == v)
            end
          end
          return t
        end,
        userdata = function()
          assertEquals('userdata', type(forbidden[0]))
          assertEquals(false, forbidden[0] == normal[0])
        end,
      }
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

G.testsuite.xml = function()
  assertEquals('', table.concat(_G.WowlessXmlErrors, '\n'))
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
      local before = { _G.GetFramesRegisteredForEvent(event) }
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
      local after = { _G.GetFramesRegisteredForEvent(event) }
      assertEquals(#before + pending, #after)
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
  {
    name = 'C_Timer.NewTimer',
    fn = function(done)
      local t
      local function cb(...)
        local args = { ... }
        done(function()
          assertEquals(1, #args)
          assertEquals(t, args[1]) -- because of eq metamethod
          assertEquals(nil, ({ [t] = true })[args[1]]) -- they're still not the same object
          assertEquals('bar', args[1].foo)
          local cfg = _G.WowlessData.Config.modules and _G.WowlessData.Config.modules.luaobjects or {}
          if cfg.tostring_metamethod then
            assertEquals(tostring(t), tostring(args[1]))
          else
            assert(tostring(t) ~= tostring(args[1]))
          end
        end)
      end
      t = G.retn(1, _G.C_Timer.NewTimer(0, cb))
      t.foo = 'bar'
    end,
  },
  {
    name = 'heartbeat clears region dirty bits',
    fn = function(done)
      local f = CreateFrame('Frame')
      f:SetSize(100, 100)
      f:SetPoint('CENTER')
      assert(f:GetRect())
      assertEquals(true, f:IsRectValid())
      f:SetWidth(200)
      assertEquals(false, f:IsRectValid())
      _G.C_Timer.After(0, function()
        done(function()
          assertEquals(not _G.__wowless, f:IsRectValid()) -- issue #518
        end)
      end)
    end,
  },
}

_G.WowlessTestFailures = {}
_G.WowlessTestsDone = false
do
  local syncIter, syncState = G.tests(function()
    return G.testsuite
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
        if _G.WowlessData.Config.addon.lua_warning_check then
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
