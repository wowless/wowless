local writeFile = require('pl.file').write
local yaml = require('wowapi.yaml')

return function(ty, fn)
  for _, p in ipairs(require('wowless.util').productList()) do
    local filename = 'data/products/' .. p .. '/' .. ty .. '.yaml'
    local data = yaml.parseFile(filename)
    fn(p, data)
    writeFile(filename, yaml.pprint(data))
  end
end
