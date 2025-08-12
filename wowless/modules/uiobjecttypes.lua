return function()
  local uiobjectTypes = {}

  local function Add(name, t)
    uiobjectTypes[name] = t
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

  local function Has(name)
    return not not uiobjectTypes[name]
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

  return {
    Add = Add,
    GetOrThrow = GetOrThrow,
    GetSandboxMetatable = GetSandboxMetatable,
    Has = Has,
    InheritsFrom = InheritsFrom,
    IsIntrinsicType = IsIntrinsicType,
  }
end
