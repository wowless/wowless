return function(api)
  local callback
  return {
    RunMacroText = function(cmd)
      if callback then
        for _, line in ipairs({ strsplit('\n', cmd) }) do
          api.CallSandbox(callback, line)
        end
      end
    end,
    SetCallback = function(cb)
      callback = cb
    end,
  }
end
