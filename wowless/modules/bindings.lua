return function()
  local bindings = {}
  local function AddBinding(name, fn)
    bindings[name] = fn
  end
  local function GetBindings()
    return bindings
  end
  return {
    AddBinding = AddBinding,
    GetBindings = GetBindings,
  }
end
