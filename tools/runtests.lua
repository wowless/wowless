local names = {}
local depth = 0
local errors = {}
local function doit(name, f)
  depth = depth + 1
  names[depth] = name
  local success, msg = securecallfunction(pcall, f)
  if not success then
    table.insert(errors, table.concat(names, ' ', 1, depth) .. '\n' .. msg)
  end
  depth = depth - 1
end
_G.oldassert = _G.assert
_G.assert = require('luassert')
_G.assert:set_parameter('TableFormatLevel', -1)
_G.describe = doit
_G.it = doit
local args
do
  local parser = require('argparse')()
  parser:option('-o --output', 'output file')
  parser:argument('specs'):args('*')
  args = parser:parse()
end
if args.output then
  io.output(args.output)
end
for _, f in ipairs(args.specs) do
  local success, msg = pcall(dofile, f)
  if not success then
    table.insert(errors, f .. '\n' .. msg)
  end
end
for _, err in ipairs(errors) do
  print(err)
end
os.exit(errors[1] and 1 or 0)
