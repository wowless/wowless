local writeFile = require('pl.file').write
local yaml = require('wowapi.yaml')
for _, fn in ipairs(arg) do
  local data = yaml.parseFile(fn)
  writeFile(fn, yaml.pprint(data))
end
