return function(datalua, log)
  local priorityNames = {}
  for k, v in pairs(datalua.globals.Enum.LogPriority) do
    priorityNames[v] = k
  end

  local function logmsg(priority, message)
    log(1, '[Log (%s)] %s', priority, message)
  end

  return {
    ['C_Log.LogErrorMessage'] = function(message)
      logmsg('Error', message)
    end,
    ['C_Log.LogMessage'] = function(message)
      logmsg('Normal', message)
    end,
    ['C_Log.LogMessageWithPriority'] = function(priority, message)
      logmsg(priorityNames[priority] or 'Unknown', message)
    end,
    ['C_Log.LogWarningMessage'] = function(message)
      logmsg('Warning', message)
    end,
  }
end
