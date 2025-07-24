local readfile = require('pl.file').read
local validate = require('wowapi.schema').validate
local yaml = require('wowapi.yaml')

local args
do
  local parser = require('argparse')()
  parser:option('-p --product', 'product')
  parser:argument('type', 'file type')
  parser:argument('file', 'file to validate')
  args = parser:parse()
end

local data = yaml.parse(readfile(args.file))
local success, t = pcall(validate, args.product, { schema = args.type }, data)
if not success then
  print('error:', yaml.pprint(t))
end
