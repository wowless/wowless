return function(log)
  local intrinsicTypes = {}

  local function Add(name, basetype, template)
    if intrinsicTypes[name] then
      log(1, 'overwriting intrinsic %s', name)
    end
    log(3, 'creating intrinsic %s', name)
    intrinsicTypes[name] = { basetype = basetype, template = template }
  end

  local function Get(name)
    return intrinsicTypes[name]
  end

  return {
    Add = Add,
    Get = Get,
  }
end
