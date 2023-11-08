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
_G.assert = require('luassert')
_G.describe = doit
_G.it = doit
local require = require
local bcache = {}
_G.require = function(s)
  if s:sub(1, 11) ~= 'build.data.' then
    return require(s)
  end
  local t = bcache[s]
  if t == nil then
    t = assert(dofile(s:gsub('%.', '/') .. '.lua'))
    bcache[s] = t
  end
  return t
end
for _, f in ipairs(arg) do
  require('wowless.ext').setglobaltable(_G)
  local success, msg = pcall(dofile, f)
  if not success then
    table.insert(errors, f .. '\n' .. msg)
  end
end
for _, err in ipairs(errors) do
  print(err)
end
os.exit(errors[1] and 1 or 0)
