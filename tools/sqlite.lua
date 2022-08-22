local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:flag('-f --full', 'also include data')
  return parser:parse()
end)()
local filebase = args.full and 'data' or 'schema'
local filename = ('build/products/%s/%s.db'):format(args.product, filebase)
require('pl.file').delete(filename)
local create, populate = require('wowapi.sqlite')(args.product)
local db = create(filename)
if args.full then
  populate(db)
end
db:close()
