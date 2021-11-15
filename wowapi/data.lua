local extLoaders = {
  lua = loadfile,
  yaml = require('wowapi.yaml').parseFile,
}

local function loaddir(dir, ext)
  local len = ext:len()
  local loader = extLoaders[ext]
  local t = {}
  for f in require('lfs').dir('data/' .. dir) do
    if f:sub(-1 - len) == '.' .. ext then
      local fn = f:sub(1, -2 - len)
      t[fn] = loader('data/' .. dir .. '/' .. f)
    end
  end
  return t
end

local function loadUIObject(name)
  local function lua(f)
    return extLoaders.lua(('data/uiobjects/%s/%s.lua'):format(name, f))
  end
  local cfg = extLoaders.yaml(('data/uiobjects/%s/%s.yaml'):format(name, name))
  local mixin = {}
  for mname, method in pairs(cfg.methods) do
    if method.status == 'implemented' then
      mixin[mname] = assert(lua(mname))
    elseif method.status == 'unimplemented' then
      if method.outputs and #method.outputs == 1 and method.outputs[1].type == 'number' then
        mixin[mname] = function() return 1 end
      elseif not method.outputs then
        mixin[mname] = function() end
      else
        error(('unsupported unimplemented method %s.%s'):format(name, mname))
      end
    else
      error(('unsupported method status %q on %s.%s'):format(method.status, name, mname))
    end
  end
  return {
    constructor = lua('init'),
    inherits = cfg.inherits,
    mixin = mixin,
  }
end

local function loadUIObjects()
  local uiobjects = {}
  for dir in require('lfs').dir('data/uiobjects') do
    if dir ~= '.' and dir ~= '..' then
      uiobjects[dir] = loadUIObject(dir)
    end
  end
  return uiobjects
end

return {
  apis = loaddir('api', 'yaml'),
  impl = loaddir('impl', 'lua'),
  state = loaddir('state', 'yaml'),
  structures = loaddir('structures', 'yaml'),
  uiobjects = loadUIObjects(),
}
