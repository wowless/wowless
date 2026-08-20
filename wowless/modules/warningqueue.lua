return function(events)
  local SendEvent = events.SendEvent
  local pending = {}

  local function QueueWarning(msg)
    table.insert(pending, msg)
  end

  local function DrainWarnings()
    for _, msg in ipairs(pending) do
      SendEvent('LUA_WARNING', msg)
    end
    table.wipe(pending)
  end

  return {
    DrainWarnings = DrainWarnings,
    QueueWarning = QueueWarning,
  }
end
