return function(env, log, security)
  local function GetScript(obj, name, bindingType)
    return obj.scripts[bindingType or 1][string.lower(name)]
  end

  local function HasScript()
    return false
  end

  local function HookScript(obj, name, script, bindingType)
    local btype = bindingType or 1
    local lname = string.lower(name)
    local scripts = obj.scripts[btype]
    local old = scripts[lname]
    if not old and btype ~= 1 then
      log(1, 'cannot hook nonexistent intrinsic precall/postcall')
      return false
    end
    local function newfn(...)
      if old then
        old(...)
      end
      script(...)
    end
    scripts[lname] = setfenv(newfn, env.genv)
    return true
  end

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

  local function SetScriptWithBindingType(obj, name, bindingType, script)
    assert(script == nil or getfenv(script) ~= _G, 'wowless bug: scripts must run in the sandbox')
    obj.scripts[bindingType][string.lower(name)] = script
  end

  local function SetScript(obj, name, script)
    return SetScriptWithBindingType(obj, name, 1, script)
  end

  return {
    GetScript = GetScript,
    HasScript = HasScript,
    HookScript = HookScript,
    RunScript = RunScript,
    SetScript = SetScript,
    SetScriptWithBindingType = SetScriptWithBindingType,
  }
end
