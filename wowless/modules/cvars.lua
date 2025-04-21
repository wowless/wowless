return function(datalua)
  local defaults = datalua.cvars
  local overrides = {}
  local function getEntry(name)
    name = name:lower()
    return overrides[name] or defaults[name]
  end
  return {
    ['C_CVar.GetCVar'] = function(name)
      local t = getEntry(name)
      return t and t.value
    end,
    ['C_CVar.GetCVarBool'] = function(name)
      local t = getEntry(name)
      return t and t.value == '1'
    end,
    ['C_CVar.GetCVarDefault'] = function(name)
      local t = defaults[name:lower()]
      return t and t.value
    end,
    ['C_CVar.RegisterCVar'] = function(name, value)
      overrides[name:lower()] = {
        name = name,
        value = value,
      }
    end,
    ['C_CVar.SetCVar'] = function(name, value)
      -- TODO assert cvar exists
      overrides[name:lower()] = {
        name = name,
        value = value,
      }
      return true
    end,
  }
end
