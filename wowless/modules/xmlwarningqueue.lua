return function(warningqueue)
  local QueueWarning = warningqueue.QueueWarning
  local pending = {}

  local function QueueXmlWarning(msg)
    table.insert(pending, msg)
  end

  local function Dump()
    for _, msg in ipairs(pending) do
      QueueWarning(msg)
    end
    table.wipe(pending)
  end

  return {
    Dump = Dump,
    QueueXmlWarning = QueueXmlWarning,
  }
end
