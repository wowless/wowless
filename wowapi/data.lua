local extLoaders = {
  lua = loadfile,
  sql = require('pl.file').read,
  yaml = require('wowapi.yaml').parseFile,
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

local function loadUIObjects()
  local uiobjects = {}
  for d in require('lfs').dir('data/uiobjects') do
    if d ~= '.' and d ~= '..' then
      uiobjects[d] = {
        cfg = extLoaders.yaml(('data/uiobjects/%s/%s.yaml'):format(d, d)),
        methods = loaddir('uiobjects/' .. d, 'lua')(),
      }
    end
  end
  return uiobjects
end

local function lazyyaml(f)
  return function()
    return extLoaders.yaml('data/' .. f .. '.yaml')
  end
end

local fns = {
  apis = loaddir('api', 'yaml'),
  builds = lazyyaml('builds'),
  cvars = lazyyaml('cvars'),
  dbdefs = loaddir('dbdefs', 'yaml'),
  events = loaddir('events', 'yaml'),
  impl = loaddir('impl', 'lua'),
  schemas = loaddir('schemas', 'yaml'),
  sqllookup = loaddir('sql/lookup', 'sql'),
  state = loaddir('state', 'yaml'),
  structures = loaddir('structures', 'yaml'),
  uiobjects = loadUIObjects,
  xml = loaddir('xml', 'yaml'),
}

return setmetatable({}, {
  __index = function(t, k)
    local v = assert(assert(fns[k], 'bad key ' .. k)())
    t[k] = v
    return v
  end,
})
