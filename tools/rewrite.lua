local lfs = require('lfs')
local pf = require('pl.file')
local yaml = require('wowapi.yaml')

local function yamlRewriter(fn)
  for filename in lfs.dir('data/api') do
    if filename:sub(-5) == '.yaml' then
      local api = yaml.parseFile('data/api/' .. filename)
      local newapi = fn(api)
      if newapi then
        pf.write('data/api/' .. filename, yaml.pprint(newapi))
      end
    end
  end
end

return {
  yaml = yamlRewriter,
}
