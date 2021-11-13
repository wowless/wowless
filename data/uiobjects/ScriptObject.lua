return {
  constructor = function(self)
    u(self).scripts = {
      [0] = {},
      [1] = {},
      [2] = {},
    }
  end,
  inherits = {},
  mixin = {
    GetScript = function(self, name, bindingType)
      return u(self).scripts[bindingType or 1][string.lower(name)]
    end,
    HasScript = function()
      return true  -- UNIMPLEMENTED
    end,
    HookScript = function(self, name, script, bindingType)
      local btype = bindingType or 1
      local lname = string.lower(name)
      local scripts = u(self).scripts[btype]
      local old = scripts[lname]
      if not old and btype ~= 1 then
        api.log(1, 'cannot hook nonexistent intrinsic precall/postcall')
        return false
      end
      scripts[lname] = function(...)
        if old then
          old(...)
        end
        script(...)
      end
      return true
    end,
    SetScript = function(self, name, script)
      api.SetScript(self, name, 1, script)
    end,
  },
}
