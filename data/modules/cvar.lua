return {
  api = function(cvarDefaults, cvars)
    local function GetCVar(var)
      return cvars[var] or cvarDefaults[var]
    end
    return {
      GetCVar = GetCVar,
      GetCVarBool = function(var)
        return GetCVar(var) == "1"
      end,
      GetCVarDefault = function(var)
        return cvarDefaults[var]
      end,
      RegisterCVar = function(var, value)
        cvars[var] = value
      end,
      SetCVar = function(var, value)
        cvars[var] = value
      end,
    }
  end,
  state = {
    'CVarDefaults',
    'CVars',
  }
}
