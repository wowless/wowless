-- A real client delivers at most this many LUA_WARNINGs per frame;
-- anything past that in the same frame's drain is silently dropped, not
-- carried over to the next one (client-verified).
local maxWarningsPerFrame = 100

return function(events)
  local SendEvent = events.SendEvent
  local pending = {}

  local function QueueWarning(msg)
    table.insert(pending, msg)
  end

  local function DrainWarnings()
    for i = 1, math.min(#pending, maxWarningsPerFrame) do
      SendEvent('LUA_WARNING', pending[i])
    end
    table.wipe(pending)
  end

  return {
    DrainWarnings = DrainWarnings,
    QueueWarning = QueueWarning,
  }
end
