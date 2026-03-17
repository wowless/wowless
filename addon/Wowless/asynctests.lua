local _, G = ...

local assertEquals = G.assertEquals

G.asynctests = {
  ['event registration and dispatch order'] = function(done)
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
  ['individual event reg before all'] = function(done)
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
  RequestTimePlayed = function(done)
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
  ['C_Timer.NewTimer'] = function(done)
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
  ['OnUpdate invocation order'] = function(done)
    if _G.__wowless then -- issue #519
      return done(function() end)
    end
    local log = {}
    local function logit(k)
      return function()
        table.insert(log, k)
      end
    end
    _G.C_Timer.After(0, function()
      local frames = {}
      for i = 1, 4 do
        frames[i] = CreateFrame('Frame')
        frames[i]:SetScript('OnUpdate', logit(i))
      end
      _G.C_Timer.After(0, function()
        frames[2]:SetScript('OnUpdate', nil)
        frames[2]:SetScript('OnUpdate', logit(2))
        _G.C_Timer.After(0, function()
          frames[2]:SetScript('OnUpdate', nil)
          _G.C_Timer.After(0, function()
            frames[2]:SetScript('OnUpdate', logit(2))
            _G.C_Timer.After(0, function()
              done(function()
                assertEquals('4,3,2,1,4,3,2,1,4,3,1,2,4,3,1', table.concat(log, ','))
              end)
            end)
          end)
        end)
      end)
    end)
  end,
  ['securecallfunction error handler throws'] = function(done)
    local before = #G.ActualLuaWarnings
    local oldhandler = _G.geterrorhandler()
    _G.seterrorhandler(function()
      error('handler error')
    end)
    _G.securecallfunction(error, 'original error')
    _G.seterrorhandler(oldhandler)
    assertEquals(before, #G.ActualLuaWarnings)
    _G.C_Timer.After(0, function()
      done(function()
        assertEquals(before + 1, #G.ActualLuaWarnings)
        table.insert(G.ExpectedLuaWarnings, G.ActualLuaWarnings[before + 1])
      end)
    end)
  end,
  ['heartbeat clears region dirty bits'] = function(done)
    local f = CreateFrame('Frame')
    f:SetSize(100, 100)
    f:SetPoint('CENTER')
    assert(f:GetRect())
    assertEquals(true, f:IsRectValid())
    f:SetWidth(200)
    assertEquals(false, f:IsRectValid())
    _G.C_Timer.After(0, function()
      done(function()
        assertEquals(true, f:IsRectValid())
      end)
    end)
  end,
  ['heartbeat does not clear dirty bits on hidden frame'] = function(done)
    local f = CreateFrame('Frame')
    f:SetSize(100, 100)
    f:SetPoint('CENTER')
    assert(f:GetRect())
    assertEquals(true, f:IsRectValid())
    f:Hide()
    f:SetWidth(200)
    assertEquals(false, f:IsRectValid())
    _G.C_Timer.After(0, function()
      done(function()
        assertEquals(false, f:IsRectValid())
      end)
    end)
  end,
  ['heartbeat does not clear dirty bits on shown but invisible frame'] = function(done)
    local p = CreateFrame('Frame')
    p:SetSize(100, 100)
    p:SetPoint('CENTER')
    local f = CreateFrame('Frame', nil, p)
    f:SetAllPoints()
    assert(f:GetRect())
    assertEquals(true, f:IsRectValid())
    assertEquals(true, f:IsVisible())
    p:Hide()
    assertEquals(true, f:IsShown())
    assertEquals(false, f:IsVisible())
    f:SetWidth(200)
    assertEquals(false, f:IsRectValid())
    _G.C_Timer.After(0, function()
      done(function()
        assertEquals(true, f:IsShown())
        assertEquals(false, f:IsVisible())
        assertEquals(false, f:IsRectValid())
      end)
    end)
  end,
  ['heartbeat clears dirty bits on invisible frame anchored to by visible frame'] = function(done)
    local p = CreateFrame('Frame')
    p:SetSize(100, 100)
    p:SetPoint('CENTER')
    p:Hide()
    local f = CreateFrame('Frame')
    f:SetSize(50, 50)
    f:SetPoint('CENTER', p)
    assert(p:GetRect())
    assertEquals(true, p:IsRectValid())
    assert(f:GetRect())
    assertEquals(true, f:IsRectValid())
    assertEquals(false, p:IsVisible())
    assertEquals(true, f:IsVisible())
    p:SetWidth(200)
    assertEquals(false, p:IsRectValid())
    _G.C_Timer.After(0, function()
      done(function()
        assertEquals(false, p:IsVisible())
        assertEquals(true, p:IsRectValid())
      end)
    end)
  end,
}
