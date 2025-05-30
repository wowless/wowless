describe('bubblewrap', function()
  local bubblewrap = require('wowless.bubblewrap')
  local function safely(fn)
    local success, msg = pcall(fn)
    debug.settaintmode('disabled')
    debug.setstacktaint(nil)
    assert(success, msg)
  end
  it('works on happy path', function()
    safely(function()
      local args
      local taintmode
      local stacktaint
      local func = bubblewrap(function(...)
        args = { ... }
        taintmode = debug.gettaintmode()
        stacktaint = debug.getstacktaint()
        return 3, 4, 5
      end)
      debug.settaintmode('rw')
      debug.setstacktaint('taintytaint')
      assert.same({ 3, 4, 5 }, { func(1, 2) })
      assert.same({ 1, 2 }, args)
      assert.same('disabled', taintmode)
      assert.same(nil, stacktaint)
      assert.same('rw', debug.gettaintmode())
      assert.same('taintytaint', debug.getstacktaint())
    end)
  end)
  it('works on error path', function()
    safely(function()
      local func = bubblewrap(error)
      debug.settaintmode('rw')
      debug.setstacktaint('taintytaint')
      local success, msg = pcall(func, 'moo')
      assert.same(false, success)
      assert.same('moo', msg)
      assert.same('rw', debug.gettaintmode())
      assert.same('taintytaint', debug.getstacktaint())
    end)
  end)
  it('fails if called securely', function()
    safely(function()
      local called = false
      local func = bubblewrap(function()
        called = true
      end)
      local success, msg = pcall(func)
      assert.same(false, success)
      assert.truthy(msg:find('wowless bug: sandbox taint mode'))
      assert.same('disabled', debug.gettaintmode())
      assert.same(nil, debug.getstacktaint())
      assert.same(false, called)
    end)
  end)
  it('fails if wrapped function exits insecurely', function()
    local func = bubblewrap(function()
      debug.settaintmode('rw')
      debug.setstacktaint('roflcopter')
    end)
    debug.settaintmode('rw')
    debug.setstacktaint('taintytaint')
    local success, msg = pcall(func)
    assert.same(false, success)
    assert.truthy(msg:find('wowless bug: host taint mode'))
    assert.same('rw', debug.gettaintmode())
    assert.same('roflcopter', debug.getstacktaint())
  end)
end)
