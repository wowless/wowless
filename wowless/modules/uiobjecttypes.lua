local uiobject = require('wowless.uiobject')

return function()
  local uiobjectTypes = {}

  local function Add(name, t)
    uiobjectTypes[name] = t
  end

  local function GetType(obj)
    return uiobject.type(obj.luarep[0])
  end

  local function GetObjectType(obj)
    return uiobjectTypes[GetType(obj)].name
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
    ty = string.lower(ty)
    return uiobjectTypes[GetType(obj)].isa[ty] or false
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
