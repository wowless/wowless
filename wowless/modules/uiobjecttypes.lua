local uiobject = require('wowless.uiobject')

return function()
  local uiobjectTypes = {}

  local function Add(name, t)
    uiobject.register(name, t.isa)
    uiobjectTypes[name] = t
  end

  local function GetObjectType(obj)
    return uiobjectTypes[obj.type].name
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
    if ty == 'object' then
      return obj.type ~= 'font'
    else
      return uiobjectTypes[obj.type].isa[ty] or false
    end
  end

  return {
    Add = Add,
    GetObjectType = GetObjectType,
    GetOrThrow = GetOrThrow,
    GetSandboxMetatable = GetSandboxMetatable,
    Has = Has,
    HasScript = HasScript,
    InheritsFrom = InheritsFrom,
    IsIntrinsicType = IsIntrinsicType,
    IsObjectType = IsObjectType,
  }
end
