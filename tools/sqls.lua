local file = require('pl.file')
local yaml = require('wowapi.yaml')
local t = {}
local deps = {}
for k, v in pairs(yaml.parse(assert(file.read('data/sql.yaml')))) do
  local f = 'data/sql/' .. k .. '.sql'
  deps[f] = true
  t[k] = {
    config = v,
    text = assert(file.read(f)),
  }
end
require('tools.util').writedeps(arg[1], deps)
file.write(arg[1], yaml.pprint(t))
