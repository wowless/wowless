return function(uiobjects, uiobjmodel)
  local uiobjectTypes = {}

  local function Add(name, t)
    uiobjectTypes[name] = t
  end

  local function GetObjectType(obj)
    local dyn = uiobjects.GetDynamicType(obj)
    if dyn then
      return uiobjectTypes[dyn].name
    end
    return uiobjmodel.GetDisplayName(obj[0])
  end

  local function GetOrThrow(name)
    local t = uiobjectTypes[name]
    if not t then
      error('unknown type ' .. name)
    end
    return t
  end

  local function GetSandboxMetatable(name)
    return GetOrThrow(name).sandboxMT
  end

  local function GetType(obj)
    return uiobjects.GetDynamicType(obj) or uiobjmodel.GetTypeName(obj[0])
  end

  local function Has(name)
    return not not uiobjectTypes[name]
  end

  local function HasScript(name, script)
    return not not uiobjectTypes[name].scripts[script]
  end

  local function InheritsFrom(a, b)
    local t = uiobjectTypes[a]
    if not t then
      error('unknown type ' .. a)
    end
    return t.isa[b]
  end

  local function IsIntrinsicType(t)
    return uiobjectTypes[string.lower(t)] ~= nil
  end

  local function IsObjectType(obj, ty)
    local lty = string.lower(ty)
    local dyn = uiobjects.GetDynamicType(obj)
    if dyn then
      return uiobjectTypes[dyn].isa[lty] or false
    end
    return uiobjmodel.IsObjectType(obj[0], lty)
  end

  return {
    Add = Add,
    GetObjectType = GetObjectType,
    GetOrThrow = GetOrThrow,
    GetSandboxMetatable = GetSandboxMetatable,
    GetType = GetType,
    Has = Has,
    HasScript = HasScript,
    InheritsFrom = InheritsFrom,
    IsIntrinsicType = IsIntrinsicType,
    IsObjectType = IsObjectType,
  }
end
