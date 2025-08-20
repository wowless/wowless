local extLoaders = {
  sql = require('pl.file').read,
  yaml = function(f)
    return require('build.' .. f:sub(1, -6):gsub('/', '.'))
  end,
}

local function loaddir(dir, ext)
  return function()
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
end

local function global(f)
  return function()
    return extLoaders.yaml('data/' .. f .. '.yaml')
  end
end

local function perproduct(f)
  return function()
    local t = {}
    for _, d in ipairs(require('pl.dir').getdirectories('data/products')) do
      t[require('path').basename(d)] = extLoaders.yaml(d .. '/' .. f .. '.yaml')
    end
    return t
  end
end

local fns = {
  apis = perproduct('apis'),
  cvars = perproduct('cvars'),
  enums = function()
    local t = {}
    for _, d in ipairs(require('pl.dir').getdirectories('data/products')) do
      t[require('path').basename(d)] = extLoaders.yaml(d .. '/globals.yaml').Enum
    end
    return t
  end,
  events = perproduct('events'),
  families = global('families'),
  gametypes = global('gametypes'),
  impl = global('impl'),
  modules = global('modules'),
  products = global('products'),
  schemas = loaddir('schemas', 'yaml'),
  scripttypes = global('scripttypes'),
  sql = global('sql'),
  stringenums = global('stringenums'),
  structures = perproduct('structures'),
  test = global('test'),
  uiobjectimpl = global('uiobjectimpl'),
  uiobjects = perproduct('uiobjects'),
  xml = perproduct('xml'),
}

return setmetatable({}, {
  __index = function(t, k)
    local v = assert(assert(fns[k], 'bad key ' .. k)())
    t[k] = v
    return v
  end,
})
