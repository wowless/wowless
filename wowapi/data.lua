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

return {
  apis = loaddir('api', 'yaml'),
  impl = loaddir('impl', 'lua'),
  state = loaddir('state', 'yaml'),
  structures = loaddir('structures', 'yaml'),
}
