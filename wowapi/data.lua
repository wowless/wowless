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
      -- TODO unify this with loader.lua
      local t = {}
      local n = method.outputs and #method.outputs or 0
      for _, output in ipairs(method.outputs or {}) do
        assert(output.type == 'number', ('unsupported type in %s.%s'):format(name, mname))
        table.insert(t, 1)
      end
      mixin[mname] = function() return unpack(t, 1, n) end
    else
      error(('unsupported method status %q on %s.%s'):format(method.status, name, mname))
    end
  end
  return {
    cfg = cfg,
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
