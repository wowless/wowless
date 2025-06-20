local api = ...
return function(self, name, script, bindingType)
  local btype = bindingType or 1
  local lname = string.lower(name)
  local scripts = self.scripts[btype]
  local old = scripts[lname]
  if not old and btype ~= 1 then
    api.log(1, 'cannot hook nonexistent intrinsic precall/postcall')
    return false
  end
  local function newfn(...)
    if old then
      old(...)
    end
    script(...)
  end
  scripts[lname] = setfenv(newfn, api.env)
  return true
end
