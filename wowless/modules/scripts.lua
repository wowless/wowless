return function(security)
  local function RunScript(obj, name, ...)
    if obj.scripts then
      for i = 0, 2 do
        local script = obj.scripts[i][string.lower(name)]
        if script then
          security.CallSandbox(script, obj.luarep, ...)
        end
      end
    end
  end

  local function SetScript(obj, name, bindingType, script)
    assert(script == nil or getfenv(script) ~= _G, 'wowless bug: scripts must run in the sandbox')
    obj.scripts[bindingType][string.lower(name)] = script
  end

  return {
    RunScript = RunScript,
    SetScript = SetScript,
  }
end
