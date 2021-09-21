local infile = unpack(arg)
local buildinfo = (function()
  local env = {}
  setfenv(loadfile(infile), env)()
  return env.TheFlatDumperBuildInfo
end)()
local outfile = string.format('%s.%s.lua', buildinfo[1], buildinfo[2])
assert(os.execute(table.concat({
  'gsutil',
  'cp',
  infile,
  'gs://wow.ferronn.dev/gscrapes/' .. outfile,
}, ' ')))
