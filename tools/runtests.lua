local names = {}
local depth = 0
local errors = {}
local function doit(name, f)
  depth = depth + 1
  names[depth] = name
  local success, msg = pcall(f)
  if not success then
    table.insert(errors, table.concat(names, ' ', 1, depth) .. '\n' .. msg)
  end
  depth = depth - 1
end
_G.assert = require('luassert')
_G.describe = doit
_G.it = doit
for _, f in ipairs(arg) do
  local success, msg = pcall(dofile, f)
  if not success then
    table.insert(errors, f .. '\n' .. msg)
  end
end
for _, err in ipairs(errors) do
  print(err)
end
os.exit(errors[1] and 1 or 0)
