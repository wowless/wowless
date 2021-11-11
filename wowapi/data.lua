local lfsdir = require('lfs').dir
local yamlparse = require('wowapi.yaml').parseFile

local apiYamls, apiLuas = (function()
  local yamls, luas = {}, {}
  for f in lfsdir('data/api') do
    local filename = 'data/api/' .. f
    if f:sub(-4) == '.lua' then
      local fn = f:sub(1, -5)
      local lua = loadfile(filename)
      luas[fn] = lua
    elseif f:sub(-5) == '.yaml' then
      local fn = f:sub(1, -6)
      local api = yamlparse(filename)
      yamls[fn] = api
    end
  end
  return yamls, luas
end)()

local apiModules = (function()
  local modules = {}
  for f in lfsdir('data/modules') do
    if f:sub(-4) == '.lua' then
      local fn = f:sub(1, -5)
      modules[fn] = loadfile('data/modules/' .. f)
    end
  end
  return modules
end)()

return {
  luas = apiLuas,
  modules = apiModules,
  yamls = apiYamls,
}
