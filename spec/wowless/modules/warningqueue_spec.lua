describe('warningqueue', function()
  local warningqueuemodule = require('wowless.modules.warningqueue')
  local function mkqueue()
    local sent = {}
    local queue = warningqueuemodule({
      SendEvent = function(event, msg)
        table.insert(sent, { event = event, msg = msg })
      end,
    })
    return queue, sent
  end

  it('delivers everything under the per-frame cap', function()
    local queue, sent = mkqueue()
    queue.QueueWarning('a')
    queue.QueueWarning('b')
    queue.DrainWarnings()
    assert.same({
      { event = 'LUA_WARNING', msg = 'a' },
      { event = 'LUA_WARNING', msg = 'b' },
    }, sent)
  end)

  it('drops everything past the 100th warning queued in one frame', function()
    local queue, sent = mkqueue()
    for i = 1, 150 do
      queue.QueueWarning(tostring(i))
    end
    queue.DrainWarnings()
    assert.equals(100, #sent)
    assert.equals('1', sent[1].msg)
    assert.equals('100', sent[100].msg)
  end)

  it('does not carry dropped warnings over to the next frame', function()
    local queue, sent = mkqueue()
    for i = 1, 150 do
      queue.QueueWarning(tostring(i))
    end
    queue.DrainWarnings()
    queue.DrainWarnings()
    assert.equals(100, #sent)
  end)
end)
