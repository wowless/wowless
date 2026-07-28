return function(datalua)
  local infos = datalua.cvars
  local values = {}
  for k, v in pairs(infos) do
    values[k] = v.default
  end
  return {
    ['C_CVar.GetCVar'] = function(name)
      return values[name:lower()]
    end,
    ['C_CVar.GetCVarBool'] = function(name)
      return values[name:lower()] == '1'
    end,
    ['C_CVar.GetCVarDefault'] = function(name)
      local t = infos[name:lower()]
      return t and t.default
    end,
    ['C_CVar.GetCVarInfo'] = function(name)
      local n = name:lower()
      local t = infos[n]
      if t then
        return values[n],
          t.default,
          not not t.account,
          not not t.character,
          not not t.locked,
          not not t.secure,
          not not t.readonly
      end
    end,
    ['C_CVar.RegisterCVar'] = function(name, value)
      -- TODO actually register
      values[name:lower()] = value
    end,
    ['C_CVar.SetCVar'] = function(name, value)
      -- TODO assert cvar exists
      values[name:lower()] = value
      return true
    end,
  }
end
