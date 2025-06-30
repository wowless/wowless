return function(api)
  local callback
  return {
    RunMacroText = function(cmd)
      for _, line in ipairs({ strsplit('\n', cmd) }) do
        api.CallSandbox(callback, line)
      end
    end,
    SetCallback = function(cb)
      callback = cb
    end,
  }
end
