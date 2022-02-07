local data = (function()
  local infile = unpack(arg)
  local env = {}
  setfenv(loadfile(infile), env)()
  local dump = require('libdeflate'):DecompressDeflate(env.TheFlatDumper)
  return setfenv(loadstring('return ' .. dump), env)()
end)()
local keys = {}
for k in pairs(data) do
  table.insert(keys, k)
end
table.sort(keys)
local pprint = require('pl.pretty').write
local tmpfile = (function()
  local name = os.tmpname()
  local f = io.open(name, 'w')
  for _, k in ipairs(keys) do
    f:write(table.concat({
      'TheFlatDumper',
      k,
      ' = ',
      pprint(data[k]),
      '\n',
    }, ''))
  end
  f:close()
  return name
end)()
local outfile = string.format('%s.%s.lua', data.BuildInfo[1], data.BuildInfo[2])
print('uploading ' .. outfile)
local outurl = 'gs://wow.ferronn.dev/gscrapes/' .. outfile
assert(os.execute(string.format('gsutil cp %q %s', tmpfile, outurl)))
os.remove(tmpfile)
