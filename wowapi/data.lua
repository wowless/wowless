local lfsdir = require('lfs').dir
local yamlparse = require('wowapi.yaml').parseFile

local apiYamls = (function()
  local yamls = {}
  for f in lfsdir('data/api') do
    if f:sub(-5) == '.yaml' then
      local fn = f:sub(1, -6)
      yamls[fn] = yamlparse('data/api/' .. f)
    end
  end
  return yamls
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

local apiStructures = (function()
  local structures = {}
  for f in lfsdir('data/structures') do
    if f:sub(-5) == '.yaml' then
      local fn = f:sub(1, -6)
      structures[fn] = yamlparse('data/structures/' .. f)
    end
  end
  return structures
end)()

return {
  modules = apiModules,
  structures = apiStructures,
  yamls = apiYamls,
}
