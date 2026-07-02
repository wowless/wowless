return function(datalua)
  local cfg = datalua.config.modules and datalua.config.modules.parentkey or {}

  local function ClearParentKey(obj)
    for k, v in pairs(obj.parent.luarep) do
      if obj.luarep == v then
        obj.parent.luarep[k] = nil
      end
    end
  end

  local function GetParentKey(obj)
    for k, v in pairs(obj.parent.luarep) do
      if obj.luarep == v then
        return k
      end
    end
    return nil
  end

  local function SetParentKey(obj, key, clear)
    if clear then
      ClearParentKey(obj)
    end
    if cfg.rawset then
      rawset(obj.parent.luarep, key, obj.luarep)
    else
      obj.parent.luarep[key] = obj.luarep
    end
  end

  return {
    ClearParentKey = ClearParentKey,
    GetParentKey = GetParentKey,
    SetParentKey = SetParentKey,
  }
end
