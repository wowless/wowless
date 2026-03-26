return function(events)
  local SendEvent = events.SendEvent
  local pending = {}

  local function QueueEvent(...)
    table.insert(pending, { ... })
  end

  local function DrainEvents()
    for _, e in ipairs(pending) do
      SendEvent(unpack(e))
    end
    table.wipe(pending)
  end

  return {
    DrainEvents = DrainEvents,
    QueueEvent = QueueEvent,
  }
end
